package salt;

import trusted.TrustedChecker;
import salt.quals.OneWayHashWithSalt;
import salt.quals.MaybeHash;

import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

/**
 * 
 * @author sdietzel
 * [25] CWE-759  Use of a One-Way Hash without a Salt
 */

@TypeQualifiers({ OneWayHashWithSalt.class, MaybeHash.class })
public class HashWithSaltChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, MaybeHash.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, OneWayHashWithSalt.class);
    }
}