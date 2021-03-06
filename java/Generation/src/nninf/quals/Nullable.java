package nninf.quals;

import java.lang.annotation.*;

import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;
import checkers.quals.ImplicitFor;

import com.sun.source.tree.Tree;

/**
 * @see NonNull
 * @see checkers.nullness.quals.Nullable
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@ImplicitFor(trees = { Tree.Kind.NULL_LITERAL })
public @interface Nullable {}
