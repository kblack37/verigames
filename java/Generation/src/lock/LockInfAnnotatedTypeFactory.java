package lock;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import javax.lang.model.element.AnnotationMirror;

import checkers.util.GraphQualifierHierarchy;
import checkers.util.MultiGraphQualifierHierarchy;
import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.ExpressionTree;
import com.sun.source.tree.MemberSelectTree;
import com.sun.source.tree.MethodInvocationTree;
import com.sun.source.tree.Tree;

import checkers.lock.quals.GuardedBy;
import checkers.quals.Unqualified;
import checkers.types.AnnotatedTypeMirror;

import checkers.util.AnnotationBuilder;
import games.GameAnnotatedTypeFactory;
import javacutils.AnnotationUtils;
import javacutils.TreeUtils;
import javacutils.TypesUtils;

public class LockInfAnnotatedTypeFactory extends GameAnnotatedTypeFactory {

    private List<String> heldLocks = new ArrayList<String>();
    private final AnnotationMirror GUARDED_BY;

	public LockInfAnnotatedTypeFactory(LockInfChecker checker) {
		super( checker );
        GUARDED_BY = AnnotationUtils.fromClass(elements, GuardedBy.class);

        addAliasedAnnotation(checkers.lock.quals.GuardedBy.class, GUARDED_BY);
        addAliasedAnnotation(net.jcip.annotations.GuardedBy.class, GUARDED_BY);

        postInit();
	}

    public void setHeldLocks(List<String> heldLocks) {
        this.heldLocks = heldLocks;
    }

    public List<String> getHeldLock() {
        return Collections.unmodifiableList(heldLocks);
    }

    private void removeHeldLocks(AnnotatedTypeMirror type) {
        AnnotationMirror guarded = type.getAnnotation(GuardedBy.class);
        if (guarded == null) {
            return;
        }

        String lock = AnnotationUtils.getElementValue(guarded, "value", String.class, false);
        if (heldLocks.contains(lock)) {
            type.clearAnnotations();
            type.addAnnotation(Unqualified.class);
        }
    }

    private AnnotationMirror createGuarded(String lock) {
        AnnotationBuilder builder =
            new AnnotationBuilder(processingEnv, GuardedBy.class.getCanonicalName());
        builder.setValue("value", lock);
        return builder.build();
    }

    private ExpressionTree receiver(ExpressionTree expr) {
        if (expr.getKind() == Tree.Kind.METHOD_INVOCATION)
            expr = ((MethodInvocationTree)expr).getMethodSelect();
        expr = TreeUtils.skipParens(expr);
        if (expr.getKind() == Tree.Kind.MEMBER_SELECT)
            return ((MemberSelectTree)expr).getExpression();
        else
            return null;
    }

    private void replaceThis(AnnotatedTypeMirror type, Tree tree) {
        if (tree.getKind() != Tree.Kind.IDENTIFIER
            && tree.getKind() != Tree.Kind.MEMBER_SELECT
            && tree.getKind() != Tree.Kind.METHOD_INVOCATION)
            return;
        ExpressionTree expr = (ExpressionTree)tree;

        if (!type.hasAnnotationRelaxed(GUARDED_BY) || isMostEnclosingThisDeref(expr))
            return;

        AnnotationMirror guardedBy = type.getAnnotation(GuardedBy.class);
        if (!"this".equals(AnnotationUtils.getElementValue(guardedBy, "value", String.class, false)))
            return;
        ExpressionTree receiver = receiver(expr);
        assert receiver != null;
        if (receiver != null) {
            AnnotationMirror newAnno = createGuarded(receiver.toString());
            type.clearAnnotations();
            type.addAnnotation(newAnno);
        }
    }

    private void replaceItself(AnnotatedTypeMirror type, Tree tree) {
        if (tree.getKind() != Tree.Kind.IDENTIFIER
            && tree.getKind() != Tree.Kind.MEMBER_SELECT
            && tree.getKind() != Tree.Kind.METHOD_INVOCATION)
            return;
        ExpressionTree expr = (ExpressionTree)tree;

        if (!type.hasAnnotationRelaxed(GUARDED_BY))
            return;

        AnnotationMirror guardedBy = type.getAnnotation(GuardedBy.class);
        if (!"itself".equals(AnnotationUtils.getElementValue(guardedBy, "value", String.class, false)))
            return;

        AnnotationMirror newAnno = createGuarded(expr.toString());
        type.clearAnnotations();
        type.addAnnotation(newAnno);
    }

    // TODO: Aliasing is not handled nicely by getAnnotation.
    // It would be nicer if we only needed to write one class here and
    // aliases were resolved internally.
    protected boolean hasGuardedBy(AnnotatedTypeMirror t) {
        return t.hasAnnotation(lock.quals.GuardedBy.class) ||
                t.hasAnnotation(checkers.lock.quals.GuardedBy.class) ||
                t.hasAnnotation(net.jcip.annotations.GuardedBy.class);
    }

    /* TODO JB: FIGURE OUT WHAT TO DO NOW THAT THIS METHOD IS FINAL */
//    @Override
//    public void annotateImplicit(Tree tree, AnnotatedTypeMirror type) {
//        if (!hasGuardedBy(type)) {
//            /* TODO: I added STRING_LITERAL to the list of types that should get defaulted.
//             * This resulted in Flow inference to infer Unqualified for strings, which is a
//             * subtype of guardedby. This broke the Constructors test case.
//             * This check ensures that an existing annotation doesn't get removed by flow.
//             * However, I'm not sure this is the nicest way to do things.
//             */
//            super.annotateImplicit(tree, type);
//        }
//        replaceThis(type, tree);
//        replaceItself(type, tree);
//        removeHeldLocks(type);
//    }

    @Override
    public AnnotationMirror aliasedAnnotation(AnnotationMirror a) {
        if (TypesUtils.isDeclaredOfName(a.getAnnotationType(),
                net.jcip.annotations.GuardedBy.class.getCanonicalName())) {
            AnnotationBuilder builder = new AnnotationBuilder(processingEnv, GuardedBy.class);
            builder.setValue("value", AnnotationUtils.getElementValue(a, "value", String.class, false));
            return builder.build();
        } else {
            return super.aliasedAnnotation(a);
        }
    }




    @Override // TODO make match LockChecker
    protected MultiGraphQualifierHierarchy.MultiGraphFactory createQualifierHierarchyFactory() {
        return new MultiGraphQualifierHierarchy.MultiGraphFactory(this);
        /*
    	MultiGraphQualifierHierarchy.MultiGraphFactory factory = createQualifierHierarchyFactory();

        factory.addQualifier(GUARDEDBY);
        factory.addQualifier(UNQUALIFIED);
        factory.addSubtype(UNQUALIFIED, GUARDEDBY);

        return factory;
        */
    }

    // TODO: how do we use this??
    private final class LockQualifierHierarchy extends GraphQualifierHierarchy {
        private final LockInfChecker lockChecker;

        public LockQualifierHierarchy(MultiGraphQualifierHierarchy.MultiGraphFactory factory) {
            super(factory, ((LockInfChecker) checker).UNQUALIFIED);
            lockChecker = (LockInfChecker) checker;
        }

        @Override
        public boolean isSubtype(AnnotationMirror rhs, AnnotationMirror lhs) {
            if (AnnotationUtils.areSameIgnoringValues(rhs, lockChecker.UNQUALIFIED)
                    && AnnotationUtils.areSameIgnoringValues(lhs, lockChecker.GUARDEDBY)) {
                return true;
            }
            // Ignore annotation values to ensure that annotation is in supertype map.
            if (AnnotationUtils.areSameIgnoringValues(lhs, lockChecker.GUARDEDBY)) {
                lhs = lockChecker.GUARDEDBY;
            }
            if (AnnotationUtils.areSameIgnoringValues(rhs, lockChecker.GUARDEDBY)) {
                rhs = lockChecker.GUARDEDBY;
            }
            return super.isSubtype(rhs, lhs);
        }
    }

}
