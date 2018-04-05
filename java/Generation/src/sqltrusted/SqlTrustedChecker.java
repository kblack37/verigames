package sqltrusted;

import trusted.TrustedChecker;
import sqltrusted.quals.SqlTrusted;
import sqltrusted.quals.SqlUntrusted;

import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import javacutils.AnnotationUtils;

import javax.lang.model.util.Elements;

/**
 * [1] CWE-89: Improper Neutralization of Special Elements used in an SQL
 * Command ('SQL Injection')
 */
@TypeQualifiers({ SqlTrusted.class, SqlUntrusted.class })
public class SqlTrustedChecker extends TrustedChecker implements
        InferenceTypeChecker {

    @Override
    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();      //TODO: Makes you think a utils is being returned

        UNTRUSTED = AnnotationUtils.fromClass(elements, SqlUntrusted.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, SqlTrusted.class);
    }
}
