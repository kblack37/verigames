package trusted;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceChecker;
import games.GameAnnotatedTypeFactory;
import games.GameVisitor;

import com.sun.source.tree.*;

public class TrustedVisitor extends GameVisitor<TrustedChecker> {

    public TrustedVisitor(TrustedChecker checker, InferenceChecker ichecker, boolean infer) {
        super(checker, ichecker, infer);
    }

    @Override
    public GameAnnotatedTypeFactory createRealTypeFactory() {
        return new TrustedAnnotatedTypeFactory(realChecker);
    }
}
