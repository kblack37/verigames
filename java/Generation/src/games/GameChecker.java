package games;

import checkers.basetype.BaseTypeChecker;
import checkers.basetype.BaseTypeVisitor;
import checkers.inference.InferenceTypeChecker;
import checkers.inference.InferenceVisitor;
import checkers.types.AnnotatedTypeFactory;
import com.sun.source.util.Trees;

import java.lang.annotation.Annotation;
import java.util.Set;

public abstract class GameChecker extends BaseTypeChecker implements InferenceTypeChecker {

    @Override
    public void initChecker() {
        //In between these brackets, is code copied directly from SourceChecker
        //except for the last line assigning the visitor
        {
            Trees trees = Trees.instance(processingEnv);
            assert( trees != null ); /*nninvariant*/
            this.trees = trees;

            this.messager = processingEnv.getMessager();
            this.messages = getMessages();

            this.visitor = createInferenceVisitor();
        }
    }

    @Override
    public Set<Class<? extends Annotation>> getSupportedTypeQualifiers() {
        return getTypeFactory().getSupportedTypeQualifiers();
    }

    @Override
    public AnnotatedTypeFactory getTypeFactory() {
        return ( (InferenceVisitor<?,?>) this.visitor ).getTypeFactory();
    }
}
