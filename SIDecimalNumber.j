/*
 * SIDecimalNumber.j
 * Foundation
 *
 * Created by Stephen Paul Ierodiaconou
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import "CPObject.j"
@import "SIDecimal.j"
@import "CPException.j"

/* The protocol is defined as : Make sure SIDecimalNumberHandler implements these methods
@protocol SIDecimalNumberBehaviors
- (CPRoundingMode)roundingMode;
- (short)scale;
- (SIDecimalNumber)exceptionDuringOperation:(SEL)operation error:(CPCalculationError)error leftOperand:(SIDecimalNumber)leftOperand rightOperand:(SIDecimalNumber)rightOperand;
@end
*/

/*! @class SIDecimalNumberHandler
    @ingroup foundation
    @brief Decimal floating point number exception and rounding behavior. This
    class is mutable.
*/
// protocols this implements <CPCoding, SIDecimalNumberBehaviors>
@implementation SIDecimalNumberHandler : CPObject
{
    CPRoundingMode _roundingMode;
    short _scale;
    BOOL _raiseOnExactness;
    BOOL _raiseOnOverflow;
    BOOL _raiseOnUnderflow;
    BOOL _raiseOnDivideByZero;
}

// initializers
- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (id)initWithRoundingMode:(CPRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero
{
    if (self = [self init])
    {
        _roundingMode = roundingMode;
        _scale = scale;
        _raiseOnExactness = exact;
        _raiseOnOverflow = overflow;
        _raiseOnUnderflow = underflow;
        _raiseOnDivideByZero = divideByZero;
    }

    return self;
}

// class methods
+ (id)decimalNumberHandlerWithRoundingMode:(CPRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero
{
    return [[self alloc] initWithRoundingMode:roundingMode scale:scale raiseOnExactness:exact raiseOnOverflow:overflow raiseOnUnderflow:underflow raiseOnDivideByZero:divideByZero];
}

+ (id)defaultDecimalNumberHandler
{
    return _cappdefaultDcmHandler;
}

// CPCoding methods
- (void)encodeWithCoder:(CPCoder)aCoder
{
}

- (id)initWithCoder:(CPCoder)aDecoder
{
}

// SIDecimalNumberBehaviors methods
- (CPRoundingMode)roundingMode
{
    return _roundingMode;
}

- (short)scale
{
    return _scale;
}

// FIXME: LOCALE?
- (SIDecimalNumber)exceptionDuringOperation:(SEL)operation error:(CPCalculationError)error leftOperand:(SIDecimalNumber)leftOperand rightOperand:(SIDecimalNumber)rightOperand
{
    // default behavior of throwing exceptions a la gnustep
    switch (error)
    {
    case CPCalculationNoError:
        return nil;
    case CPCalculationOverflow:
        if (_raiseOnOverflow)
            [CPException raise:SIDecimalNumberOverflowException reason:("A SIDecimalNumber overflow has occured. (Left operand= '" + [leftOperand  descriptionWithLocale:nil] + "' Right operand= '" + [rightOperand  descriptionWithLocale:nil] + "' Selector= '" + operation + "')") ];
        else
            return [SIDecimalNumber maximumDecimalNumber]; // there was overflow return largest possible val
        break;
    case CPCalculationUnderflow:
        if (_raiseOnUnderflow)
            [CPException raise:SIDecimalNumberUnderflowException reason:("A SIDecimalNumber underflow has occured. (Left operand= '" + [leftOperand  descriptionWithLocale:nil] + "' Right operand= '" + [rightOperand  descriptionWithLocale:nil] + "' Selector= '" + operation + "')") ];
        else
            return [SIDecimalNumber minimumDecimalNumber]; // there was underflow, return smallest possible value
        break;
    case CPCalculationLossOfPrecision:
        if (_raiseOnExactness)
            [CPException raise:SIDecimalNumberExactnessException reason:("A SIDecimalNumber has been rounded off during a calculation. (Left operand= '" + [leftOperand  descriptionWithLocale:nil] + "' Right operand= '" + [rightOperand  descriptionWithLocale:nil] + "' Selector= '" + operation + "')") ];
        else
            return nil; // Ignore.
        break;
    case CPCalculationDivideByZero:
        if (_raiseOnDivideByZero)
            [CPException raise:SIDecimalNumberDivideByZeroException reason:("A SIDecimalNumber divide by zero has occured. (Left operand= '" + [leftOperand  descriptionWithLocale:nil] + "' Right operand= '" + [rightOperand  descriptionWithLocale:nil] + "' Selector= '" + operation + "')") ];
        else
            return [SIDecimalNumber notANumber]; // Div by zero returns NaN
        break;
    default:
        [CPException raise:CPInvalidArgumentException reason:("An unknown SIDecimalNumber error has occured. (Left operand= '" + [leftOperand  descriptionWithLocale:nil] + "' Right operand= '" + [rightOperand  descriptionWithLocale:nil] + "' Selector= '" + operation + "')") ];
    }

  return nil;
}

@end

// create the default global behavior class
_cappdefaultDcmHandler = [SIDecimalNumberHandler decimalNumberHandlerWithRoundingMode:CPRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];

// After discussing with boucher about this it makes sense not to inherit, as
// CPNumber is toll free bridged and anyway its methods will need to be
// overrided here as SIDecimalNumber is not interchangable with CPNumbers.

/*! @class SIDecimalNumber
    @ingroup foundation
    @brief Decimal floating point number

    This class represents a decimal floating point number and the relavent
    mathematical operations to go with it.
    This class is mutable.
*/
@implementation SIDecimalNumber : CPObject
{
    SIDecimal _data;
}

// initializers
- (id)init
{
    if (self = [super init])
    {}
    return self;
}

/*!
    Initialise a SIDecimalNumber object with the contents of a SIDecimal object
    @param dcm the SIDecimal object to copy
    @return the reference to the receiver SIDecimalNumber
*/
- (id)initWithDecimal:(SIDecimal)dcm
{
    if (self = [self init])
        _data = SIDecimalCopy(dcm);

    return self;
}

// NOTE: long long doesnt exist in JS, so this is actually a double
- (id)initWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag
{
    if (self = [self init])
    {
        if( flag )
            mantissa *= -1;

        _data = SIDecimalMakeWithParts(mantissa, exponent);
    }

    return self;
}

- (id)initWithString:(CPString)numberValue
{
    if (self = [self init])
    {
        _data = SIDecimalMakeWithString(numberValue, nil);
        if (_data === nil)
            [CPException raise:CPInvalidArgumentException reason:"A SIDecimalNumber has been passed an invalid string. '" + numberValue + "'"];
    }

    return self;
}

- (id)initWithString:(CPString)numberValue locale:(CPDictionary)locale
{
    if (self = [self init])
    {
        _data = SIDecimalMakeWithString(numberValue,locale);
        if (!_data)
            [CPException raise:CPInvalidArgumentException reason:"A SIDecimalNumber has been passed an invalid string. '" + numberValue + "'"];
    }

    return self;
}

// class methods
+ (SIDecimalNumber)decimalNumberWithDecimal:(SIDecimal)dcm
{
    return [[self alloc] initWithDecimal:dcm];
}

+ (SIDecimalNumber)decimalNumberWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag
{
    return [[self alloc] initWithMantissa:mantissa exponent:exponent isNegative:flag];
}

+ (SIDecimalNumber)decimalNumberWithString:(CPString)numberValue
{
    return [[self alloc] initWithString:numberValue];
}

+ (SIDecimalNumber)decimalNumberWithString:(CPString)numberValue locale:(CPDictionary)locale
{
    return [[self alloc] initWithString:numberValue locale:locale];
}

+ (id)defaultBehavior
{
    return _cappdefaultDcmHandler;
}

+ (SIDecimalNumber)maximumDecimalNumber
{
    var s = @"",
        i = 0;
    for(;i < SIDecimalMaxDigits; i++)
        s += "9";
    s += "e" + SIDecimalMaxExponent;
    return [[self alloc] initWithString:s];
}

+ (SIDecimalNumber)minimumDecimalNumber
{
    var s = @"-",
        i = 0;
    for(;i < SIDecimalMaxDigits; i++)
        s += "9";
    s += "e" + SIDecimalMinExponent;
    return [[self alloc] initWithString:s];
}

+ (SIDecimalNumber)notANumber
{
    return [[self alloc] initWithDecimal:SIDecimalMakeNaN()];
}

+ (SIDecimalNumber)one
{
    return [[self alloc] initWithString:"1"];
}

+ (void)setDefaultBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    _cappdefaultDcmHandler = behavior;
}

+ (SIDecimalNumber)zero
{
    return [[self alloc] initWithString:"0"];
}

// instance methods
- (SIDecimalNumber)decimalNumberByAdding:(SIDecimalNumber)decimalNumber
{
    return [self decimalNumberByAdding:decimalNumber withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberByAdding:(SIDecimalNumber)decimalNumber withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    // FIXME: Surely this can take CPNumber (any JS number) as an argument as CPNumber is SIDecimalNumbers super normally (not here tho)
    var result = SIDecimalMakeZero(),
        res = 0,
        error = SIDecimalAdd(result, [self decimalValue], [decimalNumber decimalValue], [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:decimalNumber];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberBySubtracting:(SIDecimalNumber)decimalNumber
{
    return [self decimalNumberBySubtracting:decimalNumber withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberBySubtracting:(SIDecimalNumber)decimalNumber withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    var result = SIDecimalMakeZero(),
        error = SIDecimalSubtract(result, [self decimalValue], [decimalNumber decimalValue], [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        var res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:decimalNumber];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberByDividingBy:(SIDecimalNumber)decimalNumber
{
    return [self decimalNumberByDividingBy:decimalNumber withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberByDividingBy:(SIDecimalNumber)decimalNumber withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    var result = SIDecimalMakeZero(),
        error = SIDecimalDivide(result, [self decimalValue], [decimalNumber decimalValue], [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        var res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:decimalNumber];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberByMultiplyingBy:(SIDecimalNumber)decimalNumber
{
    return [self decimalNumberByMultiplyingBy:decimalNumber withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberByMultiplyingBy:(SIDecimalNumber)decimalNumber withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    var result = SIDecimalMakeZero(),
        error = SIDecimalMultiply(result, [self decimalValue], [decimalNumber decimalValue], [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        var res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:decimalNumber];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberByMultiplyingByPowerOf10:(short)power
{
    return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberByMultiplyingByPowerOf10:(short)power withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    var result = SIDecimalMakeZero(),
        error = SIDecimalMultiplyByPowerOf10(result, [self decimalValue], power, [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        var res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:[SIDecimalNumber decimalNumberWithString:power.toString()]];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberByRaisingToPower:(unsigned)power
{
    return [self decimalNumberByRaisingToPower:power withBehavior:_cappdefaultDcmHandler];
}

- (SIDecimalNumber)decimalNumberByRaisingToPower:(unsigned)power withBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    if (power < 0)
        return [behavior exceptionDuringOperation:_cmd error:-1 leftOperand:self rightOperand:[SIDecimalNumber decimalNumberWithString:power.toString()]];

    var result = SIDecimalMakeZero(),
        error = SIDecimalPower(result, [self decimalValue], power, [behavior roundingMode]);

    if (error > CPCalculationNoError)
    {
        var res = [behavior exceptionDuringOperation:_cmd error:error leftOperand:self rightOperand:[SIDecimalNumber decimalNumberWithString:power.toString()]];
        // Gnustep does this, not sure if it is correct behavior
        if (res != nil)
            return res; // say on overflow and no exception handling, returns max decimal val
    }
    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

- (SIDecimalNumber)decimalNumberByRoundingAccordingToBehavior:(id <SIDecimalNumberBehaviors>)behavior
{
    var result = SIDecimalMakeZero();

    SIDecimalRound(result, [self decimalValue], [behavior scale], [behavior roundingMode]);

    return [SIDecimalNumber decimalNumberWithDecimal:result];
}

// This method takes a CPNumber. Thus the parameter may be a SIDecimalNumber or a CPNumber class.
// Thus the type is checked to send the operand to the correct compare function.
- (CPComparisonResult)compare:(CPNumber)decimalNumber
{
    if ([decimalNumber class] != SIDecimalNumber)
        decimalNumber = [SIDecimalNumber decimalNumberWithString:decimalNumber.toString()];
    return SIDecimalCompare([self decimalValue], [decimalNumber decimalValue]);
}

/*!
    Unimplemented
*/
- (CPString)hash
{
    objj_exception_throw("hash: NOT YET IMPLEMENTED");
}

/*!
    The objective C type string. For compatability reasons
    @return returns a CPString containing "d"
*/
- (CPString)objCType
{
    return @"d";
}

// FIXME:  I expect here locale should be some default locale
- (CPString)stringValue
{
    return [self descriptionWithLocale:nil];
}

- (CPString)descriptionWithLocale:(CPDictionary)locale
{
    return SIDecimalString(_data, locale);
}

/*!
    Returns a new SIDecimal object (which effectively contains the
    internal decimal number representation).
    @return a new SIDecimal number copy
*/
- (SIDecimal)decimalValue
{
    return SIDecimalCopy(_data);
}

// Type Conversion Methods
- (double)doubleValue
{
    // FIXME: locale support / bounds check?
    return parseFloat([self stringValue]);
}

- (BOOL)boolValue
{
    return (SIDecimalIsZero(_data))?NO:YES;
}

- (char)charValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (float)floatValue
{
    // FIXME: locale support / bounds check?
    return parseFloat([self stringValue]);
}

- (int)intValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (long long)longLongValue
{
    // FIXME: locale support / bounds check?
    return parseFloat([self stringValue]);
}

- (long)longValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (short)shortValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (unsigned char)unsignedCharValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (unsigned int)unsignedIntValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (unsigned long)unsignedLongValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (unsigned short)unsignedShortValue
{
    // FIXME: locale support / bounds check?
    return parseInt([self stringValue]);
}

- (BOOL)isEqualToNumber:(CPNumber)aNumber
{
    return (SIDecimalCompare(SIDecimalMakeWithString(aNumber.toString(),nil), _data) == CPOrderedSame)?YES:NO;
}

// CPNumber inherited methods
+ (id)numberWithBool:(BOOL)aBoolean
{
    return [[self alloc] initWithBool:aBoolean];
}

+ (id)numberWithChar:(char)aChar
{
    return [[self alloc] initWithChar:aChar];
}

+ (id)numberWithDouble:(double)aDouble
{
    return [[self alloc] initWithDouble:aDouble];
}

+ (id)numberWithFloat:(float)aFloat
{
    return [[self alloc] initWithFloat:aFloat];
}

+ (id)numberWithInt:(int)anInt
{
    return [[self alloc] initWithInt:anInt];
}

+ (id)numberWithLong:(long)aLong
{
    return [[self alloc] initWithLong:aLong];
}

+ (id)numberWithLongLong:(long long)aLongLong
{
    return [[self alloc] initWithLongLong:aLongLong];
}

+ (id)numberWithShort:(short)aShort
{
    return [[self alloc] initWithShort:aShort];
}

+ (id)numberWithUnsignedChar:(unsigned char)aChar
{
    return [[self alloc] initWithUnsignedChar:aChar];
}

+ (id)numberWithUnsignedInt:(unsigned)anUnsignedInt
{
    return [[self alloc] initWithUnsignedInt:anUnsignedInt];
}

+ (id)numberWithUnsignedLong:(unsigned long)anUnsignedLong
{
    return [[self alloc] initWithUnsignedLong:anUnsignedLong];
}

+ (id)numberWithUnsignedLongLong:(unsigned long)anUnsignedLongLong
{
    return [[self alloc] initWithUnsignedLongLong:anUnsignedLongLong];
}

+ (id)numberWithUnsignedShort:(unsigned short)anUnsignedShort
{
    return [[self alloc] initWithUnsignedShort:anUnsignedShort];
}

- (id)initWithBool:(BOOL)value
{
    if (self = [self init])
        _data = SIDecimalMakeWithParts((value)?1:0, 0);
    return self;
}

- (id)initWithChar:(char)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithDouble:(double)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithFloat:(float)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithInt:(int)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithLong:(long)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithLongLong:(long long)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithShort:(short)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithUnsignedChar:(unsigned char)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithUnsignedInt:(unsigned)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithUnsignedLong:(unsigned long)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithUnsignedLongLong:(unsigned long long)value
{
    return [self _initWithJSNumber:value];
}

- (id)initWithUnsignedShort:(unsigned short)value
{
    return [self _initWithJSNumber:value];
}

- (id)_initWithJSNumber:value
{
    if (self = [self init])
        _data = SIDecimalMakeWithString(value.toString(), nil);
    return self;
}

@end
