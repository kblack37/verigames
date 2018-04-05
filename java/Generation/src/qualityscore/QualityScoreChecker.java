package qualityscore;

import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

import qualityscore.quals.NonQualityScore;
import qualityscore.quals.QualityScore;
import trusted.TrustedChecker;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;

/**
 *
 * Checker for picard's quality scores.
 */

@TypeQualifiers({ NonQualityScore.class, QualityScore.class })
public class QualityScoreChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();

        UNTRUSTED = AnnotationUtils.fromClass(elements, NonQualityScore.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, QualityScore.class);
    }
}