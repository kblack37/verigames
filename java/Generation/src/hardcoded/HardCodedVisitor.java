package hardcoded;

import checkers.inference.InferenceChecker;
import games.GameVisitor;
import checkers.basetype.BaseTypeChecker;

import com.sun.source.tree.CompilationUnitTree;

public class HardCodedVisitor extends GameVisitor<HardCodedChecker> {

    public HardCodedVisitor(HardCodedChecker checker, InferenceChecker ichecker, boolean infer) {
        super(checker, ichecker, infer);
    }
}
