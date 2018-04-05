package download;

import download.quals.*;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;


import trusted.TrustedChecker;

/**
 * 
 * @author sdietzel
 * [14] CSE-494 Download of Code Without Integrity Check
 */

@TypeQualifiers({ VerifiedResource.class, ExternalResource.class })
public class DownloadChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, ExternalResource.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, VerifiedResource.class);
    }
}
