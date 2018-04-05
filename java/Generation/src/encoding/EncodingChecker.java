package encoding;

import encoding.quals.*;
import javax.lang.model.util.Elements;

import trusted.TrustedChecker;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

/**
 * 
 * @author sdietzel
 * [30] CWE-838: Inappropriate Encoding for Output Context
 */

@TypeQualifiers({ UnknownEncoding.class, AppropriateEncoding.class })
public class EncodingChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, UnknownEncoding.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, AppropriateEncoding.class);
    }
}
