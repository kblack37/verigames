package random;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceChecker;
import com.sun.source.tree.CompilationUnitTree;
import trusted.TrustedChecker;
import trusted.TrustedVisitor;

public class RandomVisitor extends TrustedVisitor {


    public RandomVisitor(TrustedChecker checker, InferenceChecker iChecker, boolean infer) {
        super(checker, iChecker, infer);
    }

    @Override
    public RandomAnnotatedTypeFactory createRealTypeFactory() {
        return new RandomAnnotatedTypeFactory( (RandomChecker) checker );
    }
}
