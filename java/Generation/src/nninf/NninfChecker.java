package nninf;

import games.GameChecker;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.util.Elements;

import nninf.quals.KeyFor;
import nninf.quals.NonNull;
import nninf.quals.Nullable;
import nninf.quals.UnknownKeyFor;

import checkers.basetype.BaseTypeChecker;
import checkers.inference.InferenceTypeChecker;
import checkers.quals.TypeQualifiers;
import checkers.types.AnnotatedTypeFactory;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.AnnotatedTypeMirror.AnnotatedDeclaredType;
import checkers.types.AnnotatedTypeMirror.AnnotatedPrimitiveType;
import checkers.types.AnnotatedTypeMirror.AnnotatedTypeVariable;
import javacutils.AnnotationUtils;
import checkers.util.MultiGraphQualifierHierarchy;

import com.sun.source.tree.CompilationUnitTree;

@TypeQualifiers({ NonNull.class, Nullable.class/*, UnknownKeyFor.class, KeyFor.class*/ })
public class NninfChecker extends GameChecker {
    public AnnotationMirror NULLABLE, NONNULL, UNKNOWNKEYFOR, KEYFOR;

    public void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        initChecker(); //TODO: DECIDE IF ALL InferenceTypeCheckers are going to be Checkers and add a good spot for this
    }

    @Override
    public void initChecker() {
        final Elements elements = processingEnv.getElementUtils();
        NULLABLE = AnnotationUtils.fromClass(elements, Nullable.class);
        NONNULL  = AnnotationUtils.fromClass(elements, NonNull.class);
        // UNKNOWNKEYFOR = annoFactory.fromClass(UnknownKeyFor.class);
        // KEYFOR = annoFactory.fromClass(KeyFor.class);

        super.initChecker();

    }

    @Override
    public NninfVisitor createInferenceVisitor() {
        // The false turns off inference and enables checking the type system.
        return new NninfVisitor(this, null, false);
    }

    @Override
    public boolean needsAnnotation(AnnotatedTypeMirror ty) {
        return !(ty instanceof AnnotatedPrimitiveType
                 /*|| ty instanceof AnnotatedTypeVariable*/);
    }

    public AnnotationMirror defaultQualifier(AnnotatedTypeMirror ty) {
        if( ty instanceof AnnotatedPrimitiveType ) {
            return NONNULL;
        } else {
            return defaultQualifier();
        }
    }

    @Override
    public AnnotationMirror defaultQualifier() {
        return this.NULLABLE;
    }

    @Override
    public AnnotationMirror selfQualifier() {
        return this.NONNULL;
    }

    @Override
    public boolean withCombineConstraints() {
        return false;
    }

    //@Override
//    public boolean isSubtype(AnnotatedTypeMirror sub, AnnotatedTypeMirror sup) {
//        if (sub.getEffectiveAnnotations().isEmpty() ||
//                sup.getEffectiveAnnotations().isEmpty()) {
//            // TODO: The super method complains about empty annotations. Prevent this.
//            return true;
//        }
//        return super.isSubtype(sub, sup);
//    }
}