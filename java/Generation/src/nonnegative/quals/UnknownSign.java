package nonnegative.quals;

import java.lang.annotation.*;

import checkers.quals.*;

@TypeQualifier
@SubtypeOf({})
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@DefaultQualifierInHierarchy
public @interface UnknownSign { }
