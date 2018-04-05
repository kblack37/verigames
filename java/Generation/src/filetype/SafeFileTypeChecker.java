package filetype;

import trusted.TrustedChecker;
import filetype.quals.SafeFileType;
import filetype.quals.UnknownFileType;

import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

/**
 * 
 * @author sdietzel
 * [9]  CWE-434  Unrestricted Upload of File with Dangerous Type
 */

@TypeQualifiers({ SafeFileType.class, UnknownFileType.class })
public class SafeFileTypeChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, UnknownFileType.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, SafeFileType.class);
    }
}