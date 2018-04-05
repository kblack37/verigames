package games;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ExecutableElement;

import checkers.basetype.BaseAnnotatedTypeFactory;
import checkers.inference.ConstraintManager;
import checkers.inference.InferenceChecker;
import checkers.inference.InferenceMain;
import checkers.inference.RefinementVariable;
import checkers.source.SourceVisitor;
import checkers.types.AnnotatedTypeMirror;
import checkers.util.AnnotatedTypes;
import com.sun.source.tree.*;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceVisitor;
import checkers.types.AnnotatedTypeMirror.AnnotatedExecutableType;
import checkers.types.AnnotatedTypeMirror.AnnotatedTypeVariable;
import javacutils.InternalUtils;
import javacutils.Pair;
import javacutils.TreeUtils;

/**
 * This Visitor is a superclass of all Visitors in the game. Its purpose is to abstract common 
 * behavior and collect reorderings of constraints, since the GameSolvers often fail if the 
 * constraints are presented in a different order.
 *
 */
public class GameVisitor<Checker extends BaseTypeChecker> extends InferenceVisitor<Checker, BaseAnnotatedTypeFactory> {
	public GameVisitor(Checker checker, InferenceChecker ichecker, boolean infer) {
		super(checker, ichecker, infer);
	}

	/**
	 * Re-orders the visitation of variables. Ensures that the modifiers, type, and initializer
	 * are visited before the super call, which will generate other constraints (e.g. Subtype
	 * constraints) which depend on the other constraints having already been represented.
	 */
    @Override
    public Void visitVariable(VariableTree node, Void p) {
        //TODO: THIS IS ANOTHER COMBO BASETYPECHECKER/TREESCANNER
        Pair<Tree, AnnotatedTypeMirror> preAssCtxt = visitorState.getAssignmentContext();
        visitorState.setAssignmentContext(Pair.of((Tree) node, atypeFactory.getAnnotatedType(node)));

        try {
            boolean valid = validateTypeOf(node);

            Void r = scan(node.getModifiers(), p);
            r = scanAndReduce(node.getType(), p, r);
            r = scanAndReduce(node.getInitializer(), p, r);

            // If there's no assignment in this variable declaration, skip it.
            if (valid && node.getInitializer() != null) {
                commonAssignmentCheck(node, node.getInitializer(),
                        "assignment.type.incompatible");
            }
            return null;
        } finally {
            visitorState.setAssignmentContext(preAssCtxt);
        }
    }


    @Override
    public Void visitEnhancedForLoop(EnhancedForLoopTree node, Void p) {
        //TODO: THIS IS ANOTHER COMBO BASETYPECHECKER/TREESCANNER
        AnnotatedTypeMirror var = atypeFactory.getAnnotatedType(node.getVariable());
        AnnotatedTypeMirror iterableType =
                atypeFactory.getAnnotatedType(node.getExpression());
        AnnotatedTypeMirror iteratedType =
                AnnotatedTypes.getIteratedType(checker.getProcessingEnvironment(), atypeFactory, iterableType);
        boolean valid = validateTypeOf(node.getVariable());


        Void r = scan(node.getVariable(), p);
        r = scanAndReduce(node.getExpression(), p, r);
        r = scanAndReduce(node.getStatement(), p, r);

        if (valid) {
            commonAssignmentCheck(var, iteratedType, node.getExpression(),
                    "enhancedfor.type.incompatible", true);
        }
        return null;
    }


    //@Override
    /*public Void visitVariable(VariableTree node, Void p) {
        /* TODO: Re-orderings were causing duplicate constraints. Revisit whether we can do
         * this smarter.
        scan(node.getModifiers(), p);
        scan(node.getType(), p);
        */
        /*scan(node.getInitializer(), p);
        return super.visitVariable(node, p);
    }*/


    /**
     * Identifier's are usually a field access (providing we aren't referring to the literal "this".  Member selects
     * are field accesses.
     *
     * Don't generate access constraints for RefinementVariables.
     * Assignments used to create field boards, but no longer do because the identifier is a RefinementVariable
     *
     **/
    public void visitFieldAccess( ExpressionTree node ) {
        Element elem = TreeUtils.elementFromUse(node);
        if (elem.getKind().isField() && !node.toString().equals("this") && !node.toString().equals("super")) {
            if (!infer || !(InferenceMain.slotMgr().extractSlot(this.atypeFactory.getAnnotatedType(node)) instanceof RefinementVariable)) {
                logFieldAccess(node);
            }
        }
    }

    @Override
    public Void visitIdentifier(IdentifierTree node, Void p) {
        visitFieldAccess( node );
        return super.visitIdentifier(node, p);
    }

    @Override
    public Void visitMemberSelect( MemberSelectTree node, Void p ) {
        if(!node.getIdentifier().toString().equals("class")) {
            visitFieldAccess( node );
        }
        return super.visitMemberSelect(node, p);
    }

    @Override
    public Void visitBinary(BinaryTree node, Void p) {
        Void res = super.visitBinary(node, p);
        // Equal to tests might have created BallSizeTestConstraints
        if (node.getKind() == Tree.Kind.EQUAL_TO || node.getKind() == Tree.Kind.NOT_EQUAL_TO) {
            // Only one of operands will be cached (so only one BallSizesConstraint will be added)
            this.logStrengtheningExpression(node.getLeftOperand());
            this.logStrengtheningExpression(node.getRightOperand());
        }
        return res;
    }

    //For some reason scanAndReduce is private though it's constituent methods are public,
    //we are doing some hacky things to get around duplicate constraints, this makes those easier
    private Void scanAndReduce(Tree node, Void p, Void r) {
        return reduce(scan(node, p), r);
    }

    private Void scanAndReduce(Iterable<? extends Tree> nodes, Void p, Void r) {
        return reduce(scan(nodes, p), r);
    }

    /** Log all assignments. */
    @Override
    public Void visitAssignment(AssignmentTree node, Void p) {

        if( infer ) {
            Pair<Tree, AnnotatedTypeMirror> preAssCtxt = visitorState.getAssignmentContext();
            visitorState.setAssignmentContext(Pair.of((Tree) node.getVariable(), atypeFactory.getAnnotatedType(node.getVariable())));
            try {
                //This is a reimplementation of what happens in BaseTypeVisitor/SourceVisitor
                //But with commonAssignmentCheck happening after visiting of the left and right side
                //of an assignment.  This is necessary because we are getting SubtypeConstraints BEFORE
                //method calls and other constraints are generated for the RHS

                Void result = scan( node.getVariable(), p);
                scanAndReduce(node.getExpression(), p, result);

                final Element leftElem = TreeUtils.elementFromUse( node.getVariable() );
                if(!InferenceMain.isPerformingFlow() && leftElem!=null && leftElem.getKind().isField() ) {
                    logAssignment(node);
                }

                commonAssignmentCheck(node.getVariable(), node.getExpression(),
                        "assignment.type.incompatible");
            } finally {
                visitorState.setAssignmentContext(preAssCtxt);
            }
        } else {
            super.visitAssignment(node, p);
        }
        return null;
    }

    @Override
    public Void visitMethod(MethodTree methodTree, Void p) {
        logReceiverClassConstraints(methodTree);

        if( TreeUtils.isConstructor(methodTree) ) {
          logConstructorConstraints( methodTree );
        }
        return super.visitMethod( methodTree, p );
    }

    /** Log method invocations. */
    @Override
    public Void visitMethodInvocation(MethodInvocationTree node, Void p) {
        ProcessingEnvironment env = checker.getProcessingEnvironment();
        ExecutableElement mapGet =  TreeUtils.getMethod("java.util.Map", "get", 1, env);
        /*Element elem = TreeUtils.elementFromUse(node.getMethodSelect()).getEnclosingElement();
        System.out.println("Elem: " + elem);
        System.out.println("Kind: " + elem.getKind());
        if (elem.getKind().isField()) {
        	System.out.println("inside: " + elem);
        	logFieldAccess(node);
        }*/

        if ( infer & !InferenceMain.isPerformingFlow() ) {
            if (TreeUtils.isMethodInvocation(node, mapGet, env)) {
                // TODO: log the call to Map.get.
            } else {
                Void r = scan(node.getTypeArguments(), p);
                r = scan(node.getMethodSelect(), p);
                r = scanAndReduce(node.getArguments(), p, r);
                logMethodInvocation(node);
            }
        } else {
            super.visitMethodInvocation(node, p);
        }
        return null;
    }

    @Override
    public Void visitReturn(ReturnTree node, Void p) {
        // Don't try to check return expressions for void methods.
        if (node.getExpression() == null) {
            return null;
        }

        scan(node.getExpression(), p);

        MethodTree enclosingMethod =
            TreeUtils.enclosingMethod(getCurrentPath());

        AnnotatedExecutableType methodType = atypeFactory.getAnnotatedType(enclosingMethod);
        commonAssignmentCheck(methodType.getReturnType(), node.getExpression(),
                "return.type.incompatible", false);

        return null;
    }

    @Override
    public Void visitNewClass( NewClassTree newClassTree, Void p) {
        super.visitNewClass( newClassTree, p);
        logConstructorInvocationConstraints( newClassTree );
        return null;
    }

    @Override
    public Void visitTypeParameter( TypeParameterTree typeParameterTree, Void p) {
        //TODO JB: Because the resulting type of typeParameterTree always has the type in front
        //TODO JB: of the parameter on the upper and lower bounds, create the constraint between
        //TODO JB: these two here.  Potential fix: change the Checker-Framework behavior
        logTypeParameterConstraints( typeParameterTree );

        return super.visitTypeParameter(typeParameterTree, p);
    }
}
