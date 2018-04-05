package internal;

import internal.quals.*;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;


import trusted.TrustedChecker;

/**
 * 
 * @author sdietzel
 * [39] CWE-209: Information Exposure Through an Error Message
 */

@TypeQualifiers({ Public.class, Internal.class })
public class InternalChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, Internal.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, Public.class);
    }
}
