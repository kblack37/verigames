package nonnegative.quals;

import java.lang.annotation.*;

import checkers.quals.*;

@TypeQualifier
@SubtypeOf(UnknownSign.class)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
public @interface NonNegative { }
