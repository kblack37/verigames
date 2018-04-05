package nonnegative;

import com.sun.source.tree.*;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceChecker;
import checkers.types.AnnotatedTypeMirror;

import games.GameAnnotatedTypeFactory;
import games.GameVisitor;

public class NonNegativeVisitor extends GameVisitor<NonNegativeChecker> {
    public NonNegativeVisitor(NonNegativeChecker checker, InferenceChecker ichecker, boolean infer) {
        super(checker, ichecker, infer);
    }

    @Override
    public GameAnnotatedTypeFactory createRealTypeFactory() {
        return new NonNegativeAnnotatedTypeFactory(realChecker);
    }

    @Override
    public Void visitArrayAccess(ArrayAccessTree node, Void p) {
        super.visitArrayAccess(node, p);

        ExpressionTree index = node.getIndex();
        AnnotatedTypeMirror type = atypeFactory.getAnnotatedType(index);
        mainIsNot(type, realChecker.UNKNOWN_SIGN, "unknown.array.index", index);

        return null;
    }
}
