package filetype.quals;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

import com.sun.source.tree.Tree;

/**
 * Indicates that the contained data is known to have a safe file type to
 * receive from an untrusted source.<p/>
 *
 * For example, a web server could require that files received from clients have
 * {@code SafeFileType}s.<p/>
 *
 * The concatentation via the + operator of any two {@code SafeFileType String}s
 * is itself a {@code SafeFileType String}. This behavior should most likely be
 * removed, as it is simply inherited from the Trusted type system, and may not
 * make sense in this context. Additionally, this annotation can technically be
 * applied to other types, and this behavior of the + operator makes little
 * sense for ints (though the annotation itself also makes little sense for
 * ints).<p/>
 *
 * Null literals are implicitly given a {@code SafeFileType} annotation.
 *
 * @see UnknownFileType
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({UnknownFileType.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface SafeFileType {}
