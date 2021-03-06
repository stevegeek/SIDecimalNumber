/*
 * SIDecimalNumberTest.j
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

@import <Foundation/CPString.j>
@import <Foundation/SIDecimalNumber.j>

@implementation SIDecimalNumberTest : OJTestCase
{
    SIDecimalNumberHandler _dcmnh;
    SIDecimalNumberHandler _dcmnhWithExactness;
}

- (void)setUp
{
    if (!_dcmnh)
        _dcmnh = [SIDecimalNumberHandler decimalNumberHandlerWithRoundingMode:CPRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    if (!_dcmnhWithExactness)
        _dcmnhWithExactness = [SIDecimalNumberHandler decimalNumberHandlerWithRoundingMode:CPRoundPlain scale:0 raiseOnExactness:YES raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
}

// init
- (void)testInitialisersAndMisc
{
    // SIDecimalNumber class initialisers
    var dcmn = [[SIDecimalNumber alloc] initWithString:@"10.72342"];
    var dcm = [dcmn decimalValue];
    [self assert:-5 equals:dcm._exponent message:"initWithString: - exponent"];
    [self assert:[1,0,7,2,3,4,2] equals:dcm._mantissa message:"initWithString: - mantissa"];
    [self assert:NO equals:dcm._isNegative message:"initWithString: - sign"];
    [self assert:NO equals:dcm._isNaN message:"initWithString: - NaN is incorrectly set"];

    dcmn = [[SIDecimalNumber alloc] initWithString:@"0.000001e18" locale:nil];
    dcm = [dcmn decimalValue];
    [self assert:12 equals:dcm._exponent message:"initWithString:locale: - exponent"];
    [self assert:[1] equals:dcm._mantissa message:"initWithString:locale: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"initWithString:locale: sign"];
    [self assert:NO equals:dcm._isNaN message:"initWithString:locale: NaN is incorrectly set"];

    dcmn = [SIDecimalNumber decimalNumberWithString:@"-578e-2"];
    dcm = [dcmn decimalValue];
    [self assert:-2 equals:dcm._exponent message:"decimalNumberWithString: - exponent"];
    [self assert:[5,7,8] equals:dcm._mantissa message:"decimalNumberWithString: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"decimalNumberWithString: - sign"];
    [self assert:NO equals:dcm._isNaN message:"decimalNumberWithString: - NaN is incorrectly set"];

    dcmn = [SIDecimalNumber decimalNumberWithString:@"-0.0001e-5" locale:nil];
    dcm = [dcmn decimalValue];
    [self assert:-9 equals:dcm._exponent message:"decimalNumberWithString:locale: - exponent"];
    [self assert:[1] equals:dcm._mantissa message:"decimalNumberWithString:locale: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"decimalNumberWithString:locale: - sign"];
    [self assert:NO equals:dcm._isNaN message:"decimalNumberWithString:locale: - NaN is incorrectly set"];

    dcmn = [[SIDecimalNumber alloc] initWithDecimal:dcm];
    dcm = [dcmn decimalValue];
    [self assert:-9 equals:dcm._exponent message:"initWithDecimal: - exponent"];
    [self assert:[1] equals:dcm._mantissa message:"initWithDecimal: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"initWithDecimal: - sign"];

    dcmn = [SIDecimalNumber decimalNumberWithDecimal:dcm];
    dcm = [dcmn decimalValue];
    [self assert:-9 equals:dcm._exponent message:"decimalNumberWithDecimal: - exponent"];
    [self assert:[1] equals:dcm._mantissa message:"decimalNumberWithDecimal: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"decimalNumberWithDecimal: - sign"];

    dcmn = [[SIDecimalNumber alloc] initWithMantissa:123654 exponent:19 isNegative:YES];
    dcm = [dcmn decimalValue];
    [self assert:19 equals:dcm._exponent message:"initWithMantissa:exponent:isNegative: - exponent"];
    [self assert:[1,2,3,6,5,4] equals:dcm._mantissa message:"initWithMantissa:exponent:isNegative: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"initWithMantissa:exponent:isNegative: - sign"];

    dcmn = [SIDecimalNumber decimalNumberWithMantissa:9876543 exponent:2 isNegative:NO];
    dcm = [dcmn decimalValue];
    [self assert:2 equals:dcm._exponent message:"decimalNumberWithMantissa:exponent:isNegative: - exponent"];
    [self assert:[9,8,7,6,5,4,3] equals:dcm._mantissa message:"decimalNumberWithMantissa:exponent:isNegative: - mantissa"];
    [self assert:NO equals:dcm._isNegative message:"decimalNumberWithMantissa:exponent:isNegative: - sign"];

    // Def behavior
    [self assert:[SIDecimalNumber defaultBehavior] equals:_cappdefaultDcmHandler message:"defaultBehavior: - returned different object"];

    [SIDecimalNumber setDefaultBehavior:_dcmnhWithExactness];
    [self assertTrue:[SIDecimalNumber defaultBehavior]._raiseOnExactness message:"setDefaultBehavior: - new behavior not set"];
    [SIDecimalNumber setDefaultBehavior:_dcmnh];

    // Range and special values
    dcmn = [SIDecimalNumber maximumDecimalNumber];
    dcm = [dcmn decimalValue];
    [self assert:SIDecimalMaxExponent equals:dcm._exponent message:"maximumDecimalNumber: - exponent"];
    [self assert:[9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9] equals:dcm._mantissa message:"maximumDecimalNumber: - mantissa"];
    [self assert:NO equals:dcm._isNegative message:"maximumDecimalNumber: - sign"];

    dcmn = [SIDecimalNumber minimumDecimalNumber];
    dcm = [dcmn decimalValue];
    [self assert:SIDecimalMinExponent equals:dcm._exponent message:"minimumDecimalNumber: - exponent"];
    [self assert:[9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9] equals:dcm._mantissa message:"minimumDecimalNumber: - mantissa"];
    [self assert:YES equals:dcm._isNegative message:"minimumDecimalNumber: - sign"];

    dcmn = [SIDecimalNumber notANumber];
    dcm = [dcmn decimalValue];
    [self assert:YES equals:dcm._isNaN message:"notANumber: - NaN should be YES"];

    dcmn = [SIDecimalNumber one];
    dcm = [dcmn decimalValue];
    [self assert:0 equals:dcm._exponent message:"one: - exponent"];
    [self assert:[1] equals:dcm._mantissa message:"one: - mantissa"];
    [self assert:NO equals:dcm._isNegative message:"one: - sign"];

    dcmn = [SIDecimalNumber zero];
    dcm = [dcmn decimalValue];
    [self assert:0 equals:dcm._exponent message:"zero: - exponent"];
    [self assert:[0] equals:dcm._mantissa message:"zero: - mantissa"];
    [self assert:NO equals:dcm._isNegative message:"zero: - sign"];


    // misc
    // decimalValue <- if it hasnt been working so far, your would know.

    dcmn = [SIDecimalNumber zero];
    dcm = [dcmn boolValue];
    [self assert:false equals:dcm message:"boolValue: - should be false"];
    dcmn = [SIDecimalNumber decimalNumberWithString:@"578"];
    dcm = [dcmn boolValue];
    [self assert:true equals:dcm message:"boolValue: - should be true"];

    // exceptions
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@"111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"];
        [self fail:"initWithString: TEX1: overflow from string"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@"foo"];
        [self fail:"initWithString: TEX2: invalid string"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@".123"];
        [self fail:"initWithString: TEX3: invalid string"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@"-.123"];
        [self fail:"initWithString: TEX4: invalid string"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@"0123"];
        [self fail:"initWithString: TEX5: invalid string"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn = [[SIDecimalNumber alloc] initWithString:@"1e200"];
        [self fail:"initWithString: TEX6: exponent overflow"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try{
        dcmn = [[SIDecimalNumber alloc] initWithString:@"12312e-23421"];
        [self fail:"initWithString: TEX7: exponent underflow"];
    } catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
}

- (void)testAdd
{

    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"123"];
    var dcmn2 = [SIDecimalNumber decimalNumberWithString:@"321"];
    var dcmn3 = [dcmn1 decimalNumberByAdding:dcmn2];
    var d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberByAdding: - exponent"];
    [self assert:[4,4,4] equals:d1._mantissa message:"decimalNumberByAdding: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByAdding: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByAdding: - NaN is incorrectly set"];

    // precision throw - with behavior
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"10000000000000000000000000000000000001"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"1.00001"];
    try {
        dcmn3 = [dcmn1 decimalNumberByAdding:dcmn2 withBehavior:_dcmnhWithExactness];
        [self fail:"decimalNumberByAdding:withBehavior: TEX1 - should have throw precision error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn3 = [dcmn1 decimalNumberByAdding:dcmn2];
    }
    catch (e)
    {
        [self fail:"decimalNumberByAdding: TEX2 - should not have thrown precision error "];
    }

    // overflow
    dcmn1 = [SIDecimalNumber maximumDecimalNumber];
    dcmn2 = [SIDecimalNumber maximumDecimalNumber];
    try {
        dcmn3 = [dcmn1 decimalNumberByAdding:dcmn2];
        [self fail:"decimalNumberByAdding: TEX3 - should have thrown overflow error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }

}

- (void)testSubtract
{
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"301"];
    var dcmn2 = [SIDecimalNumber decimalNumberWithString:@"153"];
    var dcmn3 = [dcmn1 decimalNumberBySubtracting:dcmn2];
    var d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberBySubtracting: - exponent"];
    [self assert:[1,4,8] equals:d1._mantissa message:"decimalNumberBySubtracting: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberBySubtracting: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberBySubtracting: - NaN is incorrectly set"];

    // precision throw - with behavior
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1e-128"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"1"];
    try {
        dcmn3 = [dcmn1 decimalNumberBySubtracting:dcmn2 withBehavior:_dcmnhWithExactness];
        [self fail:"decimalNumberBySubtracting:withBehavior: TEX1 - should have throw precision error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn3 = [dcmn1 decimalNumberBySubtracting:dcmn2];
    }
    catch (e)
    {
        [self fail:"decimalNumberBySubtracting: TEX2 - should not have thrown precision error "];
    }

    // can we get underflow from subtraction since we cant represent anything smaller than the allowed range anyway?
}

- (void)testDivide
{
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"7126313"];
    var dcmn2 = [SIDecimalNumber decimalNumberWithString:@"1235"];
    var dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2];
    var d1 = [dcmn3 decimalValue];
    [self assert:-34 equals:d1._exponent message:"decimalNumberByDividingBy: - exponent"];
    [self assert:[5,7,7,0,2,9,3,9,2,7,1,2,5,5,0,6,0,7,2,8,7,4,4,9,3,9,2,7,1,2,5,5,0,6,0,7,2,8] equals:d1._mantissa message:"decimalNumberByDividingBy: T1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByDividingBy: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByDividingBy: - NaN is incorrectly set"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"2"];
    dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2 withBehavior:_dcmnhWithExactness];
    d1 = [dcmn3 decimalValue];
    [self assert:-1 equals:d1._exponent message:"decimalNumberByDividingBy:withBehavior: - exponent"];
    [self assert:[5] equals:d1._mantissa message:"decimalNumberByDividingBy:withBehavior: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByDividingBy:withBehavior: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByDividingBy:withBehavior: - NaN is incorrectly set"];

    // Exceptions
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"3"];
    try {
        dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2 withBehavior:_dcmnhWithExactness];
        [self fail:"decimalNumberByDividingBy:withBehavior: TEX1 - should have thrown precision error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2];
    }
    catch (e)
    {
        [self fail:"decimalNumberByDividingBy: TEX2 - should not have thrown precision error "];
    }

    // underflow  , if dcnm2 is < 10 this is LossOfPrecision, is this correct? check vs cocoa.
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"-1e-128"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"10"];
     try {
        dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2];
        [self fail:"decimalNumberByDividingBy: TEX3 - should have thrown underflow error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"-1e-128"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"0"];
     try {
        dcmn3 = [dcmn1 decimalNumberByDividingBy:dcmn2];
        [self fail:"decimalNumberByDividingBy: TEX3 - should have thrown DIV0 error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
}
*/
- (void)testMutliply
{

    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"17"];
    var dcmn2 = [SIDecimalNumber decimalNumberWithString:@"512"];
    var dcmn3 = [dcmn1 decimalNumberByMultiplyingBy:dcmn2];
    var d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberByMultiplyingBy: - exponent"];
    [self assert:[8,7,0,4] equals:d1._mantissa message:"decimalNumberByMultiplyingBy: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByMultiplyingBy: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByMultiplyingBy: - NaN is incorrectly set"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"0.0001"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"1024"];
    dcmn3 = [dcmn1 decimalNumberByMultiplyingBy:dcmn2 withBehavior:_dcmnhWithExactness];
    d1 = [dcmn3 decimalValue];
    [self assert:-4 equals:d1._exponent message:"decimalNumberByMultiplyingBy:withBehavior: - exponent"];
    [self assert:[1,0,2,4] equals:d1._mantissa message:"decimalNumberByMultiplyingBy:withBehavior: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByMultiplyingBy:withBehavior: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByMultiplyingBy:withBehavior: - NaN is incorrectly set"];

    // Exceptions
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"18302741890374918"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"123847190277982223422346878934534"];
    try {
        dcmn3 = [dcmn1 decimalNumberByMultiplyingBy:dcmn2 withBehavior:_dcmnhWithExactness];
        [self fail:"decimalNumberByMultiplyingBy:withBehavior: TEX1 - should have thrown precision error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn3 = [dcmn1 decimalNumberByMultiplyingBy:dcmn2];
    }
    catch (e)
    {
        [self fail:"decimalNumberByMultiplyingBy: TEX2 - should not have thrown precision error "];
    }

    // overflow
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"23e100"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"-13e76"];
    try {
        dcmn3 = [dcmn1 decimalNumberByMultiplyingBy:dcmn2];
        [self fail:"decimalNumberByMultiplyingBy: TEX3 - should have overflowed "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
}

- (void)testPower10
{
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"17"];
    var p = 21;
    var dcmn3 = [dcmn1 decimalNumberByMultiplyingByPowerOf10:p];
    var d1 = [dcmn3 decimalValue];
    [self assert:21 equals:d1._exponent message:"decimalNumberByMultiplyingByPowerOf10: - exponent"];
    [self assert:[1,7] equals:d1._mantissa message:"decimalNumberByMultiplyingByPowerOf10: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByMultiplyingByPowerOf10: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByMultiplyingByPowerOf10: - NaN is incorrectly set"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1e121"];
    p = -123;
    dcmn3 = [dcmn1 decimalNumberByMultiplyingByPowerOf10:p withBehavior:_dcmnhWithExactness];
    d1 = [dcmn3 decimalValue];
    [self assert:-2 equals:d1._exponent message:"decimalNumberByMultiplyingByPowerOf10:withBehavior: - exponent"];
    [self assert:[1] equals:d1._mantissa message:"decimalNumberByMultiplyingByPowerOf10:withBehavior: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByMultiplyingByPowerOf10:withBehavior: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByMultiplyingByPowerOf10:withBehavior: - NaN is incorrectly set"];

    // Exceptions
    // overflow
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1e23"];
    p = 127;
    try {
        dcmn3 = [dcmn1 decimalNumberByMultiplyingByPowerOf10:p];
        [self fail:"decimalNumberByMultiplyingByPowerOf10: TEX1 - should have overflowed "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }

}

- (void)testPower
{
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"17"];
    var p = 10;
    var dcmn3 = [dcmn1 decimalNumberByRaisingToPower:p];
    var d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberByRaisingToPower: - exponent"];
    [self assert:[2,0,1,5,9,9,3,9,0,0,4,4,9] equals:d1._mantissa message:"decimalNumberByRaisingToPower: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByRaisingToPower: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByRaisingToPower: - NaN is incorrectly set"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"54"];
    p = 2;
    dcmn3 = [dcmn1 decimalNumberByRaisingToPower:p withBehavior:_dcmnhWithExactness];
    d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberByRaisingToPower:withBehavior: - exponent"];
    [self assert:[2,9,1,6] equals:d1._mantissa message:"decimalNumberByRaisingToPower:withBehavior: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByRaisingToPower:withBehavior: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByRaisingToPower:withBehavior: - NaN is incorrectly set"];

    // Exceptions
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"123198771093489073413"];
    p = 2;
    try {
        dcmn3 = [dcmn1 decimalNumberByRaisingToPower:p withBehavior:_dcmnhWithExactness];
        [self fail:"decimalNumberByRaisingToPower:withBehavior: TEX1 - should have thrown precision error "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
    try {
        dcmn3 = [dcmn1 decimalNumberByRaisingToPower:p];
    }
    catch (e)
    {
        [self fail:"decimalNumberByRaisingToPower: TEX2 - should not have thrown precision error "];
    }

    // overflow
    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1234"];
    p = 123;
    try {
        dcmn3 = [dcmn1 decimalNumberByRaisingToPower:p];
        [self fail:"decimalNumberByRaisingToPower: TEX3 - should have overflowed "];
    }
    catch (e)
    {
        if ((e.isa) && [e name] == AssertionFailedError)
            throw e;
    }
}

- (void)testRounding
{
    var h = [SIDecimalNumberHandler decimalNumberHandlerWithRoundingMode:CPRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1.4"];
    var dcmn3 = [dcmn1 decimalNumberByRoundingAccordingToBehavior:h];
    var d1 = [dcmn3 decimalValue];
    [self assert:0 equals:d1._exponent message:"decimalNumberByRoundingAccordingToBehavior: - exponent"];
    [self assert:[1] equals:d1._mantissa message:"decimalNumberByRoundingAccordingToBehavior: - mantissa"];
    [self assert:NO equals:d1._isNegative message:"decimalNumberByRoundingAccordingToBehavior: - sign"];
    [self assert:NO equals:d1._isNaN message:"decimalNumberByRoundingAccordingToBehavior: - NaN is incorrectly set"];
}

- (void)testCompare
{
    var dcmn1 = [SIDecimalNumber decimalNumberWithString:@"17"];
    var dcmn2 = [SIDecimalNumber decimalNumberWithString:@"512"];
    var c = [dcmn1 compare:dcmn2];
    [self assert:c equals:CPOrderedAscending message:"compare: - ascending"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"1234"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"512"];
    c = [dcmn1 compare:dcmn2];
    [self assert:c equals:CPOrderedDescending message:"compare: - descending"];

    dcmn1 = [SIDecimalNumber decimalNumberWithString:@"54e123"];
    dcmn2 = [SIDecimalNumber decimalNumberWithString:@"54e123"];
    c = [dcmn1 compare:dcmn2];
    [self assert:c equals:CPOrderedSame message:"compare: - same"];
}

- (void)testStringValue
{
    var dcmn = [SIDecimalNumber decimalNumberWithString:@"512"];
    [self assert:"512" equals:[dcmn stringValue] message:"stringValue: - small number"];
    dcmn = [SIDecimalNumber decimalNumberWithString:@"10823478917236482"];
    [self assert:"10823478917236482" equals:[dcmn stringValue] message:"stringValue: - medium number"];
    dcmn = [SIDecimalNumber decimalNumberWithString:@"123456789123456789123456789e15"];
    [self assert:"123456789123456789123456789000000000000000" equals:[dcmn stringValue] message:"stringValue: - large number"];
    dcmn = [SIDecimalNumber decimalNumberWithString:@"82346.2341144"];
    [self assert:"82346.2341144" equals:[dcmn descriptionWithLocale:nil] message:"descriptionWithLocale: - large number"];
}

@end
