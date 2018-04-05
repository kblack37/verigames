package nonnegative;

import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.util.Elements;

import checkers.quals.TypeQualifiers;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.AnnotatedTypeMirror.*;
import javacutils.AnnotationUtils;

import games.GameChecker;

import nonnegative.quals.*;

@TypeQualifiers({ NonNegative.class, UnknownSign.class })
public class NonNegativeChecker extends GameChecker {
    public AnnotationMirror UNKNOWN_SIGN, NON_NEGATIVE;

    @Override
    public void initChecker() {
        super.initChecker();
        setAnnotations();
    }

    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();
        UNKNOWN_SIGN = AnnotationUtils.fromClass(elements, UnknownSign.class);
        NON_NEGATIVE = AnnotationUtils.fromClass(elements, NonNegative.class);
    }

    @Override
    public NonNegativeVisitor createInferenceVisitor() {
        return new NonNegativeVisitor(this, null, false);
    }

    @Override
    public boolean needsAnnotation(AnnotatedTypeMirror ty) {
        // TODO do something here?
        return false;
    }

    @Override
    public AnnotationMirror defaultQualifier(AnnotatedTypeMirror ty) {
        return defaultQualifier();
    }

    @Override
    public AnnotationMirror defaultQualifier() {
        return NON_NEGATIVE;
    }

    // wtf does this even do
    @Override
    public AnnotationMirror selfQualifier() {
        return UNKNOWN_SIGN;
    }

    @Override
    public boolean withCombineConstraints() {
        return false;
    }
}
