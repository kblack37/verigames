package random;

import javax.lang.model.element.ExecutableElement;
import javax.lang.model.type.TypeMirror;

import checkers.inference.InferenceUtils;
import com.sun.source.tree.BinaryTree;
import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.MethodInvocationTree;

import checkers.basetype.BaseTypeChecker;
import checkers.types.AnnotatedTypeMirror;

import checkers.types.TreeAnnotator;
import games.GameAnnotatedTypeFactory;
import javacutils.ElementUtils;
import javacutils.TreeUtils;

public class RandomAnnotatedTypeFactory extends GameAnnotatedTypeFactory {
    private final ExecutableElement nextInt;
    private final ExecutableElement nextDouble;
    private final ExecutableElement nextBoolean;
    private final ExecutableElement nextFloat;
    private final ExecutableElement nextGaussian;
    private final ExecutableElement nextLong;
    
    private final String secureRandom = "java.security.SecureRandom";

    public RandomAnnotatedTypeFactory(RandomChecker checker ) {
        super(checker);
        postInit();

        nextInt = TreeUtils.getMethod("java.util.Random", "nextInt", 0, checker.getProcessingEnvironment());
        nextDouble = TreeUtils.getMethod("java.util.Random", "nextDouble", 0, checker.getProcessingEnvironment());
        nextBoolean = TreeUtils.getMethod("java.util.Random", "nextBoolean", 0, checker.getProcessingEnvironment());
        nextFloat = TreeUtils.getMethod("java.util.Random", "nextFloat", 0, checker.getProcessingEnvironment());
        nextGaussian = TreeUtils.getMethod("java.util.Random", "nextGaussian", 0, checker.getProcessingEnvironment());
        nextLong = TreeUtils.getMethod("java.util.Random", "nextLong", 0, checker.getProcessingEnvironment());
        
    }

    @Override
    public TreeAnnotator createTreeAnnotator() {
        return new TrustedTreeAnnotator();
    }

    private class TrustedTreeAnnotator extends TreeAnnotator {
        public TrustedTreeAnnotator() {
            super(RandomAnnotatedTypeFactory.this);
        }

        /**
         * Handles String concatenation; only @Trusted + @Trusted = @Trusted.
         * Any other concatenation results in @Untursted.
         */
        @Override
        public Void visitBinary(BinaryTree tree, AnnotatedTypeMirror type) {
            if ( !InferenceUtils.isAnnotated( type)
                    && TreeUtils.isStringConcatenation(tree)) {
                AnnotatedTypeMirror lExpr = getAnnotatedType(tree.getLeftOperand());
                AnnotatedTypeMirror rExpr = getAnnotatedType(tree.getRightOperand());

                final RandomChecker randomChecker = (RandomChecker) checker;
                if (lExpr.hasAnnotation(randomChecker.TRUSTED) && rExpr.hasAnnotation(randomChecker.TRUSTED)) {
                    type.addAnnotation(randomChecker.TRUSTED);
                } else {
                    type.addAnnotation(randomChecker.UNTRUSTED);
                }
            }
            return super.visitBinary(tree, type);
        }
        
        @Override 
        public Void visitMethodInvocation(MethodInvocationTree tree, AnnotatedTypeMirror type) {
            final RandomChecker randomChecker = (RandomChecker) checker;
        	if (isNext(tree)){
    			if(secureRandom.equals(TreeUtils.elementFromUse(TreeUtils.getReceiverTree(tree)).asType().toString())) {
    				type.removeAnnotation(randomChecker.UNTRUSTED);
    				type.addAnnotation(randomChecker.TRUSTED);
        		} else {
        			type.removeAnnotation(randomChecker.TRUSTED);
        			type.addAnnotation(randomChecker.UNTRUSTED);
        		}
        	}
			return super.visitMethodInvocation(tree, type);        	
        }
        
        private boolean isNext(MethodInvocationTree tree) {
        	return TreeUtils.isMethodInvocation(tree, nextInt, checker.getProcessingEnvironment())
        			|| TreeUtils.isMethodInvocation(tree, nextDouble, checker.getProcessingEnvironment())
        			|| TreeUtils.isMethodInvocation(tree, nextFloat, checker.getProcessingEnvironment())
        			|| TreeUtils.isMethodInvocation(tree, nextLong, checker.getProcessingEnvironment())
        			|| TreeUtils.isMethodInvocation(tree, nextBoolean, checker.getProcessingEnvironment())
        			|| TreeUtils.isMethodInvocation(tree, nextGaussian, checker.getProcessingEnvironment());
        }
    }
}
