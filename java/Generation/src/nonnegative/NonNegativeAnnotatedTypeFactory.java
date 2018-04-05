package nonnegative;

import com.sun.source.tree.*;
import static com.sun.source.tree.Tree.Kind.*;

import checkers.basetype.BaseTypeChecker;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.TreeAnnotator;

import games.GameAnnotatedTypeFactory;

public class NonNegativeAnnotatedTypeFactory extends GameAnnotatedTypeFactory {

    private NonNegativeChecker nnChecker;
    public NonNegativeAnnotatedTypeFactory(NonNegativeChecker checker) {
        super(checker);

        nnChecker = checker;
        postInit();
    }

    @Override
    public TreeAnnotator createTreeAnnotator() {
        return new NonNegativeTreeAnnotator();
    }

    private class NonNegativeTreeAnnotator extends TreeAnnotator {
        public NonNegativeTreeAnnotator() {
            super(NonNegativeAnnotatedTypeFactory.this);
        }

        @Override
        public Void visitLiteral(LiteralTree tree, AnnotatedTypeMirror type) {
            if (tree.getKind() == INT_LITERAL) {
                if ((int) tree.getValue() >= 0) {
                    type.addAnnotation(nnChecker.NON_NEGATIVE);
                } else {
                    type.addAnnotation(nnChecker.UNKNOWN_SIGN);
                }
            }
            return super.visitLiteral(tree, type);
        }

        @Override
        public Void visitBinary(BinaryTree tree, AnnotatedTypeMirror type) {
            AnnotatedTypeMirror lExpr = getAnnotatedType(tree.getLeftOperand());
            AnnotatedTypeMirror rExpr = getAnnotatedType(tree.getRightOperand());

            if (tree.getKind() != MINUS &&
                    lExpr.hasAnnotation(nnChecker.NON_NEGATIVE) &&
                    rExpr.hasAnnotation(nnChecker.NON_NEGATIVE)) {
                type.addAnnotation(nnChecker.NON_NEGATIVE);
            } else {
                type.addAnnotation(nnChecker.UNKNOWN_SIGN);
            }

            return super.visitBinary(tree, type);
        }
    }
}
