package hardcoded;

import checkers.inference.InferenceUtils;
import com.sun.source.tree.BinaryTree;
import com.sun.source.tree.CompilationUnitTree;

import checkers.basetype.BaseTypeChecker;
import checkers.types.AnnotatedTypeMirror;

import checkers.types.TreeAnnotator;
import games.GameAnnotatedTypeFactory;
import javacutils.TreeUtils;

public class HardCodedAnnotatedTypeFactory extends GameAnnotatedTypeFactory {

    private HardCodedChecker hcChecker;

    public HardCodedAnnotatedTypeFactory(HardCodedChecker checker) {
        super(checker);
        postInit();
    }

    @Override
    public TreeAnnotator createTreeAnnotator() {
        return new HardCodedTreeAnnotator();
    }

    private class HardCodedTreeAnnotator extends TreeAnnotator {
        public HardCodedTreeAnnotator() {
            super(HardCodedAnnotatedTypeFactory.this);
        }

        /**
         * Handles String concatenation.
         *
         * s1 + s2 results in s3
         *
         * s3 is @NotHardCoded if either s1 or s2 is @NotHardCoded.
         *
         * This contrasts with the original trusted checker, where both s1 and
         * s2 would have to be trusted in order for s3 to be trusted.
         */
        @Override
        public Void visitBinary(BinaryTree tree, AnnotatedTypeMirror type) {
            if (!InferenceUtils.isAnnotated( type )
                    && TreeUtils.isStringConcatenation(tree)) {
                AnnotatedTypeMirror lExpr = getAnnotatedType(tree.getLeftOperand());
                AnnotatedTypeMirror rExpr = getAnnotatedType(tree.getRightOperand());

                final HardCodedChecker hcChecker = (HardCodedChecker) checker;
                if (lExpr.hasAnnotation(hcChecker.NOTHARDCODED) || rExpr.hasAnnotation(hcChecker.NOTHARDCODED)) {
                    type.addAnnotation(hcChecker.NOTHARDCODED);
                } else {
                    type.addAnnotation(hcChecker.MAYBEHARDCODED);
                }
            }
            return super.visitBinary(tree, type);
        }
    }
}
