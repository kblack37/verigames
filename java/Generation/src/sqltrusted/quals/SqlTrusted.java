package sqltrusted.quals;

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
 * Represents data that is trusted for use in SQL queries.<p/>
 *
 * Prevents attacks such as SQL injection by ensuring that a query passed to a
 * SQL server is composed only of parts that either originated locally or has
 * undergone some form of verification.<p/>
 *
 * It is the responsibility of the programmer to provide a correct sanitization
 * routine to convert from {@code SqlUntrusted} data to {@code SqlTrusted} data,
 * if she wishes to use {@code SqlUntrusted} data in SQL queries.<p/>
 *
 * The annotated JDK stub file requires that SQL Strings passed to the SQL API
 * be {@code SqlTrusted}.<p/>
 *
 * All literals are trusted by default.<p/>
 *
 * The concatenation or addition of two trusted values via the + operator is
 * also considered trusted. We should consider extending this to support other
 * arithmetic operations.<p/>
 *
 * @see SqlUntrusted
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({SqlUntrusted.class})
@ImplicitFor(
    trees={
        Tree.Kind.BOOLEAN_LITERAL,
        Tree.Kind.CHAR_LITERAL,
        Tree.Kind.DOUBLE_LITERAL,
        Tree.Kind.FLOAT_LITERAL,
        Tree.Kind.INT_LITERAL,
        Tree.Kind.LONG_LITERAL,
        Tree.Kind.NULL_LITERAL,
        Tree.Kind.STRING_LITERAL,
    })
public @interface SqlTrusted {}
