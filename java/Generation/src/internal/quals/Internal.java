package internal.quals;

import java.lang.annotation.*;

import com.sun.source.tree.Tree;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * Indicates that the contained data may not be acceptable to display to the
 * end-user.<p/>
 *
 * All types are given this annotation implicitly.<p/>
 *
 * @see Public
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
// TODO is this necessary since it's the default qualifier anyway?
@ImplicitFor(
	    trees={
	        Tree.Kind.STRING_LITERAL
	    })
public @interface Internal {}
