package encrypted;

import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

import encrypted.quals.*;

import trusted.TrustedChecker;

/**
 * 
 * @author sdietzel
 * [8]  CWE-311  Missing Encryption of Sensitive Data
 */

@TypeQualifiers({ Encrypted.class, Plaintext.class })
public class EncryptedChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, Plaintext.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, Encrypted.class);
    }
}