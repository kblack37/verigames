package random;

import checkers.types.AnnotatedTypeFactory;
import trusted.TrustedChecker;
import random.quals.Random;
import random.quals.MaybeRandom;

import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

import com.sun.source.tree.CompilationUnitTree;

/**
 * 
 * @author sdietzel
 * [31] CWE-330: Use of Insufficiently Random Values
 */

@TypeQualifiers({ Random.class, MaybeRandom.class })
public class RandomChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, MaybeRandom.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, Random.class);
    }
}