package trusted;


import games.GameAnnotatedTypeFactory;
import games.GameChecker;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.util.Elements;

import trusted.quals.Trusted;
import trusted.quals.Untrusted;
import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import checkers.types.AnnotatedTypeFactory;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.TypeHierarchy;
import checkers.types.AnnotatedTypeMirror.AnnotatedDeclaredType;
import checkers.types.AnnotatedTypeMirror.AnnotatedPrimitiveType;
import checkers.types.AnnotatedTypeMirror.AnnotatedTypeVariable;
import javacutils.AnnotationUtils;

import com.sun.source.tree.CompilationUnitTree;

/**
 * 
 * The Trusted checker is a generic checker for expressing objects as "trusted" or not.
 * It should most likely be only used abstractly; specific subtypes with their own
 * qualifiers should be created to represent most categories of trusted (e.g. for SQL
 * or OS commands).
 * 
 */
@TypeQualifiers({ Trusted.class, Untrusted.class })
public class TrustedChecker extends GameChecker {
    public AnnotationMirror UNTRUSTED, TRUSTED;

    @Override
    public void initChecker() {
    	super.initChecker();
    	setAnnotations();
    }

    protected void setAnnotations() {
        final Elements elements = processingEnv.getElementUtils();
        UNTRUSTED = AnnotationUtils.fromClass(elements, Untrusted.class);
        TRUSTED   = AnnotationUtils.fromClass(elements, Trusted.class);
    }

    public TrustedVisitor createInferenceVisitor() {
        // The false turns off inference and enables checking the type system.
        return new TrustedVisitor(this, null, false);
    }

//    @Override
//    public boolean isValidUse(AnnotatedDeclaredType declarationType,
//            AnnotatedDeclaredType useType) {
//        return true;
//    }

    @Override
    public boolean needsAnnotation(AnnotatedTypeMirror ty) {
        return true;
    }

    public AnnotationMirror defaultQualifier(AnnotatedTypeMirror ty) {
        if( ! needsAnnotation( ty ) ) {
           return TRUSTED;
        } else {
           return UNTRUSTED;
        }
    }

    @Override
    public AnnotationMirror defaultQualifier() {
        return this.UNTRUSTED;
    }

    @Override
    public AnnotationMirror selfQualifier() {
        return this.TRUSTED;
    }

    @Override
    public boolean withCombineConstraints() {
        return false;
    }
    
}