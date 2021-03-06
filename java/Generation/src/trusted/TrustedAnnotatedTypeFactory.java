package trusted;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceUtils;
import checkers.types.AnnotatedTypeMirror;

import checkers.types.TreeAnnotator;
import games.GameAnnotatedTypeFactory;
import javacutils.TreeUtils;

import com.sun.source.tree.BinaryTree;
import com.sun.source.tree.CompilationUnitTree;

public class TrustedAnnotatedTypeFactory extends GameAnnotatedTypeFactory {

    public TrustedAnnotatedTypeFactory(TrustedChecker checker) {
        super(checker);
        postInit();
    }

    @Override
    public TreeAnnotator createTreeAnnotator() {
        return new TrustedTreeAnnotator(checker);
    }

    private class TrustedTreeAnnotator extends TreeAnnotator {
        public TrustedTreeAnnotator(BaseTypeChecker checker) {
            super(TrustedAnnotatedTypeFactory.this);
        }

        /**
         * Handles String concatenation; only @Trusted + @Trusted = @Trusted.
         * Any other concatenation results in @Untrusted.
         */
        @Override
        public Void visitBinary(BinaryTree tree, AnnotatedTypeMirror type) {
            if ( !InferenceUtils.isAnnotated( type )
                    && TreeUtils.isStringConcatenation(tree)) {
                AnnotatedTypeMirror lExpr = getAnnotatedType(tree.getLeftOperand());
                AnnotatedTypeMirror rExpr = getAnnotatedType(tree.getRightOperand());

                final TrustedChecker trustedChecker = (TrustedChecker) checker;
                if (lExpr.hasAnnotation(trustedChecker.TRUSTED) && rExpr.hasAnnotation(trustedChecker.TRUSTED)) {
                    type.addAnnotation(trustedChecker.TRUSTED);
                } else {
                    type.addAnnotation(trustedChecker.UNTRUSTED);
                }
            }
            return super.visitBinary(tree, type);
        }
    }
}
