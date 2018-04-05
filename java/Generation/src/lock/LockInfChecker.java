package lock;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.util.Elements;

import com.sun.source.tree.CompilationUnitTree;

import games.GameChecker;
import lock.quals.*;
import checkers.quals.Unqualified;
import checkers.quals.TypeQualifiers;
import checkers.types.AnnotatedTypeFactory;
import checkers.types.AnnotatedTypeMirror;
import checkers.types.AnnotatedTypeMirror.AnnotatedPrimitiveType;
import checkers.types.AnnotatedTypeMirror.AnnotatedTypeVariable;
import javacutils.AnnotationUtils;
import checkers.util.GraphQualifierHierarchy;
import checkers.util.MultiGraphQualifierHierarchy;

@TypeQualifiers({GuardedBy.class})
public class LockInfChecker extends GameChecker {
	public AnnotationMirror GUARDEDBY, UNQUALIFIED;

    public void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        initChecker(); //TODO: DECIDE IF ALL InferenceTypeCheckers are going to be Checkers and add a good spot for this
    }
    @Override
    public void initChecker() {
        super.initChecker();
        final Elements elements = processingEnv.getElementUtils();

        GUARDEDBY = AnnotationUtils.fromClass(elements, GuardedBy.class);
        UNQUALIFIED  = AnnotationUtils.fromClass(elements, Unqualified.class);
    }

    @Override
    public LockInfVisitor createInferenceVisitor() {
        // The false turns off inference and enables checking the type system.
        return new LockInfVisitor(this, null, false);
    }

	@Override
	public boolean needsAnnotation(AnnotatedTypeMirror ty) {
        return !(ty instanceof AnnotatedPrimitiveType
                || ty instanceof AnnotatedTypeVariable);
	}

    @Override
    public AnnotationMirror defaultQualifier(AnnotatedTypeMirror ty) {
        return defaultQualifier();
    }

	@Override
	public AnnotationMirror defaultQualifier() {
		return this.UNQUALIFIED;
	}

	@Override
	public AnnotationMirror selfQualifier() {
		return this.UNQUALIFIED;
	}

	@Override
	public boolean withCombineConstraints() {
		return false;
	}

}
