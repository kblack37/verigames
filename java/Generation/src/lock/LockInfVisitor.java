package lock;

import java.lang.annotation.Annotation;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;

import checkers.inference.InferenceChecker;
import lock.quals.GuardedBy;
import lock.quals.Holding;

import checkers.basetype.BaseTypeChecker;
import checkers.source.Result;
import checkers.source.SourceChecker;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.AnnotatedTypeMirror.AnnotatedDeclaredType;
import checkers.types.AnnotatedTypeMirror.AnnotatedExecutableType;
import javacutils.AnnotationUtils;
import javacutils.TreeUtils;

import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.ExpressionTree;
import com.sun.source.tree.IdentifierTree;
import com.sun.source.tree.MemberSelectTree;
import com.sun.source.tree.MethodInvocationTree;
import com.sun.source.tree.MethodTree;
import com.sun.source.tree.SynchronizedTree;
import com.sun.source.tree.Tree;

import games.GameVisitor;

public class LockInfVisitor extends GameVisitor<LockInfChecker> {

	LockInfAnnotatedTypeFactory lockatypeFactory;

	public LockInfVisitor(LockInfChecker checker, InferenceChecker iChecker, boolean infer) {
		super(checker, iChecker, infer);

		this.lockatypeFactory = (LockInfAnnotatedTypeFactory) createRealTypeFactory(); //TODO: WHy is this here?
	}


    @Override
    public LockInfAnnotatedTypeFactory createRealTypeFactory() {
        return new LockInfAnnotatedTypeFactory(realChecker);
    }

    @Override
    public Void visitIdentifier(IdentifierTree node, Void p) {
        AnnotatedTypeMirror type = atypeFactory.getAnnotatedType(node);
        String lock = objectGuardedByLock(type);
        if ( "this".equals(lock)) {
        	lock = receiver(node);
        }
        if (lockatypeFactory.hasGuardedBy(type) && (lock == null || !lockatypeFactory.getHeldLock().contains(lock))) {
        	checker.report(Result.failure("unguarded.access", node, type), node);
        }
        return super.visitIdentifier(node, p);
    }

    @Override
    public Void visitMemberSelect(MemberSelectTree node, Void p) {
        AnnotatedTypeMirror type = atypeFactory.getAnnotatedType(node);
        String lock = objectGuardedByLock(type);
        if ( "this".equals(lock)) {
        	lock = receiver(node);
        }
        if (lockatypeFactory.hasGuardedBy(type) && (lock == null || !lockatypeFactory.getHeldLock().contains(lock))) {
        	checker.report(Result.failure("unguarded.access", node, type), node);
        }
        return super.visitMemberSelect(node, p);
    }

    private <T> List<T> append(List<T> lst, T o) {
        if (o == null)
            return lst;

        List<T> newList = new ArrayList<T>(lst.size() + 1);
        newList.addAll(lst);
        newList.add(o);
        return newList;
    }

    @Override
    public Void visitSynchronized(SynchronizedTree node, Void p) {
        List<String> prevLocks = lockatypeFactory.getHeldLock();
        try {
            List<String> locks = append(prevLocks, TreeUtils.skipParens(node.getExpression()).toString());
            lockatypeFactory.setHeldLocks(locks);
            return super.visitSynchronized(node, p);
        } finally {
        	lockatypeFactory.setHeldLocks(prevLocks);
        }
    }

    @Override
    public Void visitMethod(MethodTree node, Void p) {
        List<String> prevLocks = lockatypeFactory.getHeldLock();
        List<String> locks = prevLocks;
        try {
            ExecutableElement method = TreeUtils.elementFromDeclaration(node);
            if (method.getModifiers().contains(Modifier.SYNCHRONIZED)
                || method.getKind() == ElementKind.CONSTRUCTOR) {
                if (method.getModifiers().contains(Modifier.STATIC)) {
                    String enclosingClass = method.getEnclosingElement().getSimpleName().toString();
                    locks = append(locks, enclosingClass + ".class");
                } else {
                    locks = append(locks, "this");
                }
            }

            List<String> methodLocks = methodHolding(method);
            if (!methodLocks.isEmpty()) {
                locks = new ArrayList<String>(locks);
                locks.addAll(methodLocks);
            }
            lockatypeFactory.setHeldLocks(locks);

            return super.visitMethod(node, p);
        } finally {
        	lockatypeFactory.setHeldLocks(prevLocks);
        }
    }

    private String receiver(ExpressionTree methodSel) {
        if (methodSel.getKind() == Tree.Kind.IDENTIFIER) {
            return "this";
        } else if (methodSel.getKind() == Tree.Kind.MEMBER_SELECT) {
            return ((MemberSelectTree)methodSel).getExpression().toString();
        } else {
            checker.errorAbort("LockVisitor found unknown receiver tree type: " + methodSel);
            return null;
        }
    }

    @Override
    public Void visitMethodInvocation(MethodInvocationTree node, Void p) {
        // does it introduce new locks
        ExecutableElement methodElt = TreeUtils.elementFromUse(node);

        String lock = receiver(node.getMethodSelect());
        if (methodElt.getSimpleName().contentEquals("lock")) {
            List<String> locks = append(lockatypeFactory.getHeldLock(), lock);
            lockatypeFactory.setHeldLocks(locks);
        } else if (methodElt.getSimpleName().contentEquals("unlock")) {
            List<String> locks = new ArrayList<String>(lockatypeFactory.getHeldLock());
            locks.remove(lock);
            lockatypeFactory.setHeldLocks(locks);
        }

        // does it require holding a lock
        List<String> methodLocks = methodHolding(methodElt);
        if (!methodLocks.isEmpty()
            && !lockatypeFactory.getHeldLock().containsAll(methodLocks)) {
            checker.report(Result.failure("unguarded.invocation",
                    methodElt, methodLocks), node);
        }

        return super.visitMethodInvocation(node, p);
    }

    @Override
    protected boolean checkOverride(MethodTree overriderTree,
            AnnotatedDeclaredType enclosingType,
            AnnotatedExecutableType overridden,
            AnnotatedDeclaredType overriddenType,
            Void p) {

        List<String> overriderLocks = methodHolding(TreeUtils.elementFromDeclaration(overriderTree));
        List<String> overriddenLocks = methodHolding( overridden.getElement() );

        boolean isValid = overriddenLocks.containsAll(overriderLocks);

        if (!isValid) {
            checker.report(Result.failure("override.holding.invalid",
                    TreeUtils.elementFromDeclaration(overriderTree),
                    //enclosingType.getElement(), overridden.getElement(),
                    //overriddenType.getElement(),
                    overriderLocks, overriddenLocks), overriderTree);
        }

        return super.checkOverride(overriderTree, enclosingType, overridden, overriddenType, p) && isValid;
    }

    @Override
    protected void checkMethodInvocability(AnnotatedExecutableType method,
            MethodInvocationTree node) {
    }

    protected List<String> methodHolding(ExecutableElement element) {
        AnnotationMirror holding = atypeFactory.getDeclAnnotation(element, Holding.class);
        AnnotationMirror guardedBy
            = atypeFactory.getDeclAnnotation(element, net.jcip.annotations.GuardedBy.class);
        if (holding == null && guardedBy == null)
            return Collections.emptyList();

        List<String> locks = new ArrayList<String>();

        if (holding != null) {
            List<String> holdingValue = AnnotationUtils.getElementValueArray(holding, "value", String.class, false);
            locks.addAll(holdingValue);
        }
        if (guardedBy != null) {
            String guardedByValue = AnnotationUtils.getElementValue(guardedBy, "value", String.class, false);
            locks.add(guardedByValue);
        }

        return locks;
    }
    

    
    protected String objectGuardedByLock(AnnotatedTypeMirror type) {
    	Set<AnnotationMirror> annotations = type.getAnnotations();
    	if (annotations.isEmpty()) {
    		return null;
    	}
        AnnotationMirror guardedBy = type.getAnnotation(GuardedBy.class);
        if (guardedBy == null) { guardedBy = type.getAnnotation(checkers.lock.quals.GuardedBy.class); }
        if (guardedBy == null) { guardedBy = type.getAnnotation(net.jcip.annotations.GuardedBy.class); }
        if (guardedBy == null) { return null; }
        return AnnotationUtils.getElementValue(guardedBy, "value", String.class, false);
        	
    }

    @Override
    public boolean isValidUse(AnnotatedDeclaredType declarationType,
            AnnotatedDeclaredType useType) {
        return true;
    }

}
