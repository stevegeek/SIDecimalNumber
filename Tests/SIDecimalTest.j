/*
 * SIDecimalTest.j
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
@import <Foundation/SIDecimal.j>

@implementation SIDecimalTest : OJTestCase

- (void)testInitialisers
{
    // max digits
    [self assertNotNull:SIDecimalMakeWithString(@"9999999999999999999999999999999999") message:"SIDecimalMakeWithString() Tmx1: max digits string"];
    [self assertNotNull:SIDecimalMakeWithString(@"-1111111111111111111111111111111111") message:"SIDecimalMakeWithString() Tmx2: negative max digits string"];

    // too big digit, round
    var dcm = SIDecimalMakeWithString(@"11111111111111111111111111111111111111111");
    [self assertNotNull:dcm message:"SIDecimalMakeWithString() Tb1: mantissa rounding string"];
    [self assert:3 equals:dcm._exponent message:"SIDecimalMakeWithString() Tb1: exponent"];
    [self assert:[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1] equals:dcm._mantissa message:"SIDecimalMakeWithString() Tb1: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalMakeWithString() Tb1: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithString() Tb1: NaN is incorrectly set"];

    // format tests
    dcm = SIDecimalMakeWithString(@"+0.01e+1");
    [self assertNotNull:dcm message:"SIDecimalMakeWithString() Tf1: mantissa rounding string"];
    [self assert:-1 equals:dcm._exponent message:"SIDecimalMakeWithString() Tf1: exponent"];
    [self assert:[1] equals:dcm._mantissa message:"SIDecimalMakeWithString() Tf1: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalMakeWithString() Tf1: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithString() Tf1: NaN is incorrectly set"];

    dcm = SIDecimalMakeWithString(@"+99e-5");
    [self assertNotNull:dcm message:"SIDecimalMakeWithString() Tf2: mantissa rounding string"];
    [self assert:-5 equals:dcm._exponent message:"SIDecimalMakeWithString() Tf2: exponent"];
    [self assert:[9,9] equals:dcm._mantissa message:"SIDecimalMakeWithString() Tf2: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalMakeWithString() Tf2: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithString() Tf2: NaN is incorrectly set"];

    dcm = SIDecimalMakeWithString(@"-1234.5678e100");
    [self assertNotNull:dcm message:"SIDecimalMakeWithString() Tf3: mantissa rounding string"];
    [self assert:96 equals:dcm._exponent message:"SIDecimalMakeWithString() Tf3: exponent"];
    [self assert:[1,2,3,4,5,6,7,8] equals:dcm._mantissa message:"SIDecimalMakeWithString() Tf3: mantissa"];
    [self assert:YES equals:dcm._isNegative message:"SIDecimalMakeWithString() Tf3: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithString() Tf3: NaN is incorrectly set"];

    dcm = SIDecimalMakeWithString(@"0.00000000000000000000000001");
    [self assertNotNull:dcm message:"SIDecimalMakeWithString() Tf4: mantissa rounding string"];
    [self assert:-26 equals:dcm._exponent message:"SIDecimalMakeWithString() Tf4: exponent"];
    [self assert:[1] equals:dcm._mantissa message:"SIDecimalMakeWithString() Tf4: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalMakeWithString() Tf4: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithString() Tf4: NaN is incorrectly set"];

    dcm = SIDecimalMakeWithString(@"000000000000000000");
    [self assertNull:dcm message:"SIDecimalMakeWithString() Tf5: Should be invalid"];

    // too large return nil
    [self assertNull:SIDecimalMakeWithString(@"111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111") message:"SIDecimalMakeWithString() To1: number overflow handling"];
    [self assertNull:SIDecimalMakeWithString(@"-1e1000") message:"SIDecimalMakeWithString() To2: exponent overflow not caught"];
    [self assertNull:SIDecimalMakeWithString(@"-1e-2342") message:"SIDecimalMakeWithString() To3: exponent underflow not caught"];

    // Tests for invalid strings
    [self assertNull:SIDecimalMakeWithString(@"abc") message:"SIDecimalMakeWithString() Ti1: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"123a") message:"SIDecimalMakeWithString() Ti2: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"12.7e") message:"SIDecimalMakeWithString() Ti3: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"e") message:"SIDecimalMakeWithString() Ti4: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"12 ") message:"SIDecimalMakeWithString() Ti5: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"1 2 3") message:"SIDecimalMakeWithString() Ti6: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"e10") message:"SIDecimalMakeWithString() Ti7: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"123ee") message:"SIDecimalMakeWithString() Ti8: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"0001") message:"SIDecimalMakeWithString() Ti9: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"-0001") message:"SIDecimalMakeWithString() Ti10: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@".123") message:"SIDecimalMakeWithString() Ti11: catch of invalid number string"];
    [self assertNull:SIDecimalMakeWithString(@"-.1") message:"SIDecimalMakeWithString() Ti12: catch of invalid number string"];

    //test make with parts
    dcm = SIDecimalMakeWithParts(10127658,2);
    [self assert:2 equals:dcm._exponent message:"SIDecimalMakeWithParts() Tmp1: exponent"];
    [self assert:[1,0,1,2,7,6,5,8] equals:dcm._mantissa message:"SIDecimalMakeWithParts() Tmp1: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalMakeWithParts() Tmp1: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithParts() Tmp1: NaN is incorrectly set"];
    dcm = SIDecimalMakeWithParts(-1000000,0);
    [self assert:6 equals:dcm._exponent message:"SIDecimalMakeWithParts() Tmp2: exponent"];
    [self assert:[1] equals:dcm._mantissa message:"SIDecimalMakeWithParts() Tmp2: mantissa"];
    [self assert:YES equals:dcm._isNegative message:"SIDecimalMakeWithParts() Tmp2: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalMakeWithParts() Tmp2: NaN is incorrectly set"];

    [self assertNull:SIDecimalMakeWithParts(1,10000) message:"SIDecimalMakeWithParts() Tmp3: exponent overflow not caught"];
    [self assertNull:SIDecimalMakeWithParts(-1,-1000) message:"SIDecimalMakeWithParts() Tmp4: exponent underflow not caught"];
}

- (void)testZeros
{
    var dcm = SIDecimalMakeWithString(@"0");
    [self assertTrue:SIDecimalIsZero(dcm) message:"SIDecimalMakeWithString(0) and SIDecimalIsZero()"];
    dcm = SIDecimalMakeWithString(@"-0.000000000000e-0");
    [self assertTrue:SIDecimalIsZero(dcm) message:"SIDecimalMakeWithString(0) and SIDecimalIsZero()"];
    dcm = SIDecimalMakeWithParts(0,0);
    [self assertTrue:SIDecimalIsZero(dcm) message:"SIDecimalMakeWithParts(0)"];
    dcm = SIDecimalMakeZero();
    [self assertTrue:SIDecimalIsZero(dcm) message:"SIDecimalMakeZero()"];
}

- (void)testOnes
{
    var dcm = SIDecimalMakeOne();
    [self assertTrue:SIDecimalIsOne(dcm) message:"SIDecimalMakeOne() and SIDecimalIsOne()"];
    dcm = SIDecimalMakeWithString(@"1.00000e1");
    [self assertTrue:SIDecimalIsOne(dcm) message:"SIDecimalMakeWithString(1)"];
    dcm = SIDecimalMakeWithString(@"0.00100000e-3");
    [self assertTrue:SIDecimalIsOne(dcm) message:"SIDecimalMakeWithString(1)"];
    [self assert:1 equals:dcm._mantissa[0] message:"SIDecimalMakeWithString(1)"];
}

- (void)testNormalize
{
    dcm1 = SIDecimalMakeWithString( @"200" );
    dcm2 = SIDecimalMakeWithString( @"2" );
    [self assert:0 equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tn1:call" ];
    [self assert:[2,0,0] equals:dcm1._mantissa message:"SIDecimalNormalise() Tn1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalNormalise() Tn1: exponent"];
    [self assert:[2] equals:dcm2._mantissa message:"SIDecimalNormalise() Tn1: mantissa"];
    [self assert:0 equals:dcm2._exponent message:"SIDecimalNormalise() Tn1: exponent"];

    dcm1 = SIDecimalMakeWithString( @"0.001" );
    dcm2 = SIDecimalMakeWithString( @"123" );
    [self assert:0 equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tn2:call" ];
    [self assert:[1] equals:dcm1._mantissa message:"SIDecimalNormalise() Tn2: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalNormalise() Tn2: exponent"];
    [self assert:[1,2,3,0,0,0] equals:dcm2._mantissa message:"SIDecimalNormalise() Tn2: mantissa"];
    [self assert:-3 equals:dcm2._exponent message:"SIDecimalNormalise() Tn2: exponent"];

    dcm1 = SIDecimalMakeWithString( @"123" );
    dcm2 = SIDecimalMakeWithString( @"0.001" );
    [self assert:0 equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tn3:call" ];
    [self assert:[1] equals:dcm2._mantissa message:"SIDecimalNormalise() Tn3: mantissa"];
    [self assert:-3 equals:dcm2._exponent message:"SIDecimalNormalise() Tn3: exponent"];
    [self assert:[1,2,3,0,0,0] equals:dcm1._mantissa message:"SIDecimalNormalise() Tn3: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalNormalise() Tn3: exponent"];

    dcm1 = SIDecimalMakeWithString( @"-1e-7" );
    dcm2 = SIDecimalMakeWithString( @"-21e-8" );
    [self assert:0 equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tn4:call" ];
    [self assert:[1,0] equals:dcm1._mantissa message:"SIDecimalNormalise() Tn4: mantissa"];
    [self assert:-8 equals:dcm1._exponent message:"SIDecimalNormalise() Tn4: exponent"];
    [self assert:[2,1] equals:dcm2._mantissa message:"SIDecimalNormalise() Tn4: mantissa"];
    [self assert:-8 equals:dcm2._exponent message:"SIDecimalNormalise() Tn4: exponent"];

    // these will result in one number becoming zero.
    dcm1 = SIDecimalMakeWithString( @"1e0" );
    dcm2 = SIDecimalMakeWithString( @"10000000000000000000000000000000000001e2" );
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tnp1:call should ret LossOfPrecision" ];
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalNormalise() Tnp1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalNormalise() Tnp1: exponent"];
    [self assert:[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1] equals:dcm2._mantissa message:"SIDecimalNormalise() Tnp1: mantissa"];
    [self assert:2 equals:dcm2._exponent message:"SIDecimalNormalise() Tnp1: exponent"];

    dcm1 = SIDecimalMakeWithString( @"10000000000000000000000000000000000001e2" );
    dcm2 = SIDecimalMakeWithString( @"1e0" );
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tnp2:call should ret LossOfPrecision" ];
    [self assert:[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1] equals:dcm1._mantissa message:"SIDecimalNormalise() Tnp2: mantissa"];
    [self assert:2 equals:dcm1._exponent message:"SIDecimalNormalise() Tnp2:exponent"];
    [self assert:[0] equals:dcm2._mantissa message:"SIDecimalNormalise() Tnp2: mantissa"];
    [self assert:0 equals:dcm2._exponent message:"SIDecimalNormalise() Tnp2: exponent"];

    dcm1 = SIDecimalMakeWithString( @"10000000000000000000000000000000000001e127" );
    dcm2 = SIDecimalMakeWithString( @"1e0" );
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tnp3:call should ret LossOfPrecision" ];
    [self assert:[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1] equals:dcm1._mantissa message:"SIDecimalNormalise() Tnp3: mantissa"];
    [self assert:127 equals:dcm1._exponent message:"SIDecimalNormalise() Tnp3: exponent"];
    [self assert:[0] equals:dcm2._mantissa message:"SIDecimalNormalise() Tnp3: mantissa"];
    [self assert:0 equals:dcm2._exponent message:"SIDecimalNormalise() Tnp3: exponent"];

    dcm1 = SIDecimalMakeWithString( @"1e-3" );
    dcm2 = SIDecimalMakeWithString( @"1e36" );
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalNormalize(dcm1,dcm2,CPRoundDown) message:"SIDecimalNormalise() Tnp4:call should ret LossOfPrecision" ];
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalNormalise() Tnp4: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalNormalise() Tnp4: exponent"];
    [self assert:[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] equals:dcm2._mantissa message:"SIDecimalNormalise() Tnp4: mantissa"];
    [self assert:-1 equals:dcm2._exponent message:"SIDecimalNormalise() Tnp4: exponent"];
}


- (void)testRound
{
    var dcm = SIDecimalMakeWithString(@"0.00123");
    SIDecimalRound(dcm,dcm,3,CPRoundUp);
    [self assert:[2] equals:dcm._mantissa message:"SIDecimalRound() Tr1: mantissa"];
    [self assert:-3 equals:dcm._exponent message:"SIDecimalRound() Tr1: exponent"];

    // plain
    var dcm1 = SIDecimalMakeZero();
    dcm = SIDecimalMakeWithString(@"123.456");
    SIDecimalRound(dcm1,dcm,0,CPRoundPlain);
    [self assert:[1,2,3] equals:dcm1._mantissa message:"SIDecimalRound() Tp1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tp1: exponent"];

    SIDecimalRound(dcm1,dcm,2,CPRoundPlain);
    [self assert:[1,2,3,4,6] equals:dcm1._mantissa message:"SIDecimalRound() Tp2: mantissa"];
    [self assert:-2 equals:dcm1._exponent message:"SIDecimalRound() Tp2: exponent"];

    SIDecimalRound(dcm1,dcm,-2,CPRoundPlain);
    [self assert:[1] equals:dcm1._mantissa message:"SIDecimalRound() Tp3: mantissa"];
    [self assert:2 equals:dcm1._exponent message:"SIDecimalRound() Tp3: exponent"];

    SIDecimalRound(dcm1,dcm,-4,CPRoundPlain);
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalRound() Tp4: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tp4: exponent"];

    SIDecimalRound(dcm1,dcm,6,CPRoundPlain);
    [self assert:[1,2,3,4,5,6] equals:dcm1._mantissa message:"SIDecimalRound() Tp5: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalRound() Tp5: exponent"];

    // down
    SIDecimalRound(dcm1,dcm,0,CPRoundDown);
    [self assert:[1,2,3] equals:dcm1._mantissa message:"SIDecimalRound() Td1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Td1: exponent"];

    SIDecimalRound(dcm1,dcm,2,CPRoundDown);
    [self assert:[1,2,3,4,5] equals:dcm1._mantissa message:"SIDecimalRound() Td2: mantissa"];
    [self assert:-2 equals:dcm1._exponent message:"SIDecimalRound() Td2: exponent"];

    SIDecimalRound(dcm1,dcm,-2,CPRoundDown);
    [self assert:[1] equals:dcm1._mantissa message:"SIDecimalRound() Td3: mantissa"];
    [self assert:2 equals:dcm1._exponent message:"SIDecimalRound() Td3: exponent"];

    SIDecimalRound(dcm1,dcm,-4,CPRoundDown);
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalRound() Td4: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Td4: exponent"];

    SIDecimalRound(dcm1,dcm,6,CPRoundDown);
    [self assert:[1,2,3,4,5,6] equals:dcm1._mantissa message:"SIDecimalRound() Td5: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalRound() Td5: exponent"];

    // up
    SIDecimalRound(dcm1,dcm,0,CPRoundUp);
    [self assert:[1,2,4] equals:dcm1._mantissa message:"SIDecimalRound() Tu1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tu1: exponent"];

    SIDecimalRound(dcm1,dcm,2,CPRoundUp);
    [self assert:[1,2,3,4,6] equals:dcm1._mantissa message:"SIDecimalRound() Tu2: mantissa"];
    [self assert:-2 equals:dcm1._exponent message:"SIDecimalRound() Tu2: exponent"];

    SIDecimalRound(dcm1,dcm,-2,CPRoundUp);
    [self assert:[2] equals:dcm1._mantissa message:"SIDecimalRound() Tu3: mantissa"];
    [self assert:2 equals:dcm1._exponent message:"SIDecimalRound() Tu3: exponent"];

    SIDecimalRound(dcm1,dcm,-4,CPRoundUp);
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalRound() Tu4: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tu4: exponent"];

    SIDecimalRound(dcm1,dcm,6,CPRoundUp);
    [self assert:[1,2,3,4,5,6] equals:dcm1._mantissa message:"SIDecimalRound() Tu5: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalRound() Tu5: exponent"];

    // bankers
    SIDecimalRound(dcm1,dcm,0,CPRoundBankers);
    [self assert:[1,2,3] equals:dcm1._mantissa message:"SIDecimalRound() Tb1: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tb1: exponent"];

    SIDecimalRound(dcm1,dcm,2,CPRoundBankers);
    [self assert:[1,2,3,4,6] equals:dcm1._mantissa message:"SIDecimalRound() Tb2: mantissa"];
    [self assert:-2 equals:dcm1._exponent message:"SIDecimalRound() Tb2: exponent"];

    SIDecimalRound(dcm1,dcm,-2,CPRoundBankers);
    [self assert:[1] equals:dcm1._mantissa message:"SIDecimalRound() Tb3: mantissa"];
    [self assert:2 equals:dcm1._exponent message:"SIDecimalRound() Tb3: exponent"];

    SIDecimalRound(dcm1,dcm,-4,CPRoundBankers);
    [self assert:[0] equals:dcm1._mantissa message:"SIDecimalRound() Tb4: mantissa"];
    [self assert:0 equals:dcm1._exponent message:"SIDecimalRound() Tb4: exponent"];

    SIDecimalRound(dcm1,dcm,6,CPRoundBankers);
    [self assert:[1,2,3,4,5,6] equals:dcm1._mantissa message:"SIDecimalRound() Tb5: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalRound() Tb5: exponent"];

    // Noscale
    SIDecimalRound(dcm1,dcm,SIDecimalNoScale,CPRoundPlain);
    [self assert:[1,2,3,4,5,6] equals:dcm1._mantissa message:"SIDecimalRound() Tns1: mantissa"];
    [self assert:-3 equals:dcm1._exponent message:"SIDecimalRound() Tns1: exponent"];
}

- (void)testCompare
{
    var dcm1 = SIDecimalMakeWithString(@"75836");
    var dcm = SIDecimalMakeWithString(@"75836");
    var c = SIDecimalCompare(dcm1,dcm);
    [self assert:CPOrderedSame equals:c message:"SIDecimalCompare() Tc1: should be same"];

    dcm1 = SIDecimalMakeWithString(@"75836");
    dcm = SIDecimalMakeWithString(@"75836e-9");
    c = SIDecimalCompare(dcm1,dcm);
    [self assert:CPOrderedDescending equals:c message:"SIDecimalCompare() Tc2: should be descending"];

    dcm1 = SIDecimalMakeWithString(@"823479");
    dcm = SIDecimalMakeWithString(@"7082371231252");
    c = SIDecimalCompare(dcm1,dcm);
    [self assert:CPOrderedAscending equals:c message:"SIDecimalCompare() Tc3: should be descending"];

    dcm1 = SIDecimalMakeWithString(@"0.00000000002");
    dcm = SIDecimalMakeWithString(@"-1e-9");
    c = SIDecimalCompare(dcm1,dcm);
    [self assert:CPOrderedDescending equals:c message:"SIDecimalCompare() Tc4: should be descending"];

    dcm1 = SIDecimalMakeWithString(@"-23412345123e12");
    dcm = SIDecimalMakeWithString(@"-1e100");
    c = SIDecimalCompare(dcm1,dcm);
    [self assert:CPOrderedDescending equals:c message:"SIDecimalCompare() Tc4: should be descending"];
}

- (void)testCompact
{
    var dcm = SIDecimalMakeZero();
    dcm._mantissa = [0,0,0,0,1,0,0,0,0,1];
    dcm._exponent = 2;
    SIDecimalCompact(dcm);
    [self assert:2 equals:dcm._exponent message:"SIDecimalCompact() Tcm1: exponent"];
    [self assert:[1,0,0,0,0,1] equals:dcm._mantissa message:"SIDecimalCompact() Tcm1: mantissa"];

    dcm = SIDecimalMakeZero();
    dcm._mantissa = [0,0,0,0,1,2,0,0,0,0];
    dcm._exponent = -4;
    dcm._isNegative = YES;
    SIDecimalCompact(dcm);
    [self assert:0 equals:dcm._exponent message:"SIDecimalCompact() Tcm2: exponent"];
    [self assert:[1,2] equals:dcm._mantissa message:"SIDecimalCompact() Tcm2: mantissa"];
    [self assert:YES equals:dcm._isNegative message:"SIDecimalCompact() Tcm2: sign"];

    dcm = SIDecimalMakeZero();
    dcm._mantissa = [1,2,0,0,0,0];
    dcm._exponent = -1;
    SIDecimalCompact(dcm);
    [self assert:3 equals:dcm._exponent message:"SIDecimalCompact() Tcm3: exponent"];
    [self assert:[1,2] equals:dcm._mantissa message:"SIDecimalCompact() Tcm3: mantissa"];
    [self assert:NO equals:dcm._isNegative message:"SIDecimalCompact() Tcm3: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalCompact() Tcm3: NaN is incorrectly set"];

    dcm = SIDecimalMakeZero();
    dcm._mantissa = [8,9,0,0,0,0,1,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    dcm._exponent = -20;
    dcm._isNegative = YES;
    SIDecimalCompact(dcm);
    [self assert:-5 equals:dcm._exponent message:"SIDecimalCompact() Tcm4: exponent"];
    [self assert:[8,9,0,0,0,0,1,2,3] equals:dcm._mantissa message:"SIDecimalCompact() Tcm4: mantissa"];
    [self assert:YES equals:dcm._isNegative message:"SIDecimalCompact() Tcm4: sign"];
    [self assert:NO equals:dcm._isNaN message:"SIDecimalCompact() Tcm4: NaN is incorrectly set"];
}

- (void)testAdd
{
    // test addition of positives
    var d1 = SIDecimalMakeWithString(@"1"),
        d2 = SIDecimalMakeWithParts(1, 0),
        dcm = SIDecimalMakeZero(),
        i = 50;
    while (i--)
        [self assert:SIDecimalAdd(d1, d1, d2, CPRoundPlain) equals:CPCalculationNoError message:"SIDecimalAdd() Tap1: addition"];
    [self assert:0 equals:d1._exponent message:"SIDecimalAdd() Tap1: exponent"];
    [self assert:[5,1] equals:d1._mantissa message:"SIDecimalAdd() Tap1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalAdd() Tap1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalAdd() Tap1: NaN is incorrectly set"];

    // test addition with negatives
    d1 = SIDecimalMakeWithString(@"-1");
    d2 = SIDecimalMakeWithString(@"-1e-10");
    [self assert:CPCalculationNoError equals:SIDecimalAdd(d1, d1, d2, CPRoundPlain) message:"SIDecimalAdd() Tan1: addition of 2 negatives"];
    [self assert:-10 equals:d1._exponent message:"SIDecimalAdd() Tan1: exponent"];
    [self assert:[1,0,0,0,0,0,0,0,0,0,1] equals:d1._mantissa message:"SIDecimalAdd() Tan1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalAdd() Tan1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalAdd() Tan1: NaN is incorrectly set"];

    d1 = SIDecimalMakeWithString(@"-5");
    d2 = SIDecimalMakeWithString(@"11");
    [self assert:CPCalculationNoError equals:SIDecimalAdd(d1, d1, d2, CPRoundPlain) message:"SIDecimalAdd() Tan2: addition with negatives"];
    [self assert:0 equals:d1._exponent message:"SIDecimalAdd() Tan2: exponent"];
    [self assert:[6] equals:d1._mantissa message:"SIDecimalAdd() Tan2: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalAdd() Tan2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalAdd() Tan2: NaN is incorrectly set"];

    d1 = SIDecimalMakeWithString(@"11");
    d2 = SIDecimalMakeWithString(@"-12");
    [self assert:CPCalculationNoError equals:SIDecimalAdd(d1, d1, d2, CPRoundPlain) message:"SIDecimalAdd() Tan3: addition with negatives"];
    [self assert:0 equals:d1._exponent message:"SIDecimalAdd() Tan3: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalAdd() Tan3: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalAdd() Tan3: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalAdd() Tan3: NaN is incorrectly set"];

    // FIXME: test mantissa overflow handling - is there a loss of precision?? not according to gnustep - check cocoa!!!! CPCalculationLossOfPrecision?
    d1 = SIDecimalMakeWithString(@"12345");
    d2 = SIDecimalMakeWithString(@"99999999999999999999999999999999999999");
    [self assert:0 equals:SIDecimalAdd(d1, d1, d2, CPRoundPlain) message:"SIDecimalAdd() Tapc1: addition with mantissa overflow and rounding"];
    [self assert:1 equals:d1._exponent message:"SIDecimalAdd() Tapc1: exponent"];
    [self assert:[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4] equals:d1._mantissa message:"SIDecimalAdd() Tapc1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalAdd() Tapc1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalAdd() Tapc1: NaN is incorrectly set"];

    d1 = SIDecimalMakeWithString(@"1e127");
    d2 = SIDecimalMakeWithString(@"99999999999999999999999999999999999999");
    [self assert:SIDecimalAdd(d1, d1, d2, CPRoundPlain) equals:CPCalculationLossOfPrecision message:"SIDecimalAdd() Tapc2: addition loss of precision"];

    // Overflow
    d1 = SIDecimalMakeWithString(@"1e127");
    d2 = SIDecimalMakeWithString(@"99999999999999999999999999999999999999e127");
    [self assert:SIDecimalAdd(d1, d1, d2, CPRoundPlain) equals:CPCalculationOverflow message:"SIDecimalAdd() Tao1: addition loss of precision"];
}

- (void)testSubtract
{
    var d1 = SIDecimalMakeZero();
    var d2 = SIDecimalMakeWithString(@"0.875");
    var d3 = SIDecimalMakeWithString(@"12.67");
    [self assert:CPCalculationNoError equals:SIDecimalSubtract(d1,d2,d3,CPRoundPlain) message:"SIDecimalSubtract(): Ts1: Should succeed"];
    [self assert:-3 equals:d1._exponent message:"SIDecimalSubtract(): Ts1: exponent"];
    [self assert:[1,1,7,9,5] equals:d1._mantissa message:"SIDecimalSubtract(): Ts1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalSubtract(): Ts1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalSubtract(): Ts1: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-0.875");
    d3 = SIDecimalMakeWithString(@"-12.67");
    [self assert:CPCalculationNoError equals:SIDecimalSubtract(d1,d2,d3,CPRoundPlain) message:"SIDecimalSubtract(): Ts2: Should succeed"];
    [self assert:-3 equals:d1._exponent message:"SIDecimalSubtract(): Ts2: exponent"];
    [self assert:[1,1,7,9,5] equals:d1._mantissa message:"SIDecimalSubtract(): Ts2: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalSubtract(): Ts2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalSubtract(): Ts2: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-0.875");
    d3 = SIDecimalMakeWithString(@"12.67e2");
    [self assert:CPCalculationNoError equals:SIDecimalSubtract(d1,d2,d3,CPRoundPlain) message:"SIDecimalSubtract(): Ts3: Should succeed"];
    [self assert:-3 equals:d1._exponent message:"SIDecimalSubtract(): Ts3: exponent"];
    [self assert:[1,2,6,7,8,7,5] equals:d1._mantissa message:"SIDecimalSubtract(): Ts3: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalSubtract(): Ts3: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalSubtract(): Ts3: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"0.875");
    d3 = SIDecimalMakeWithString(@"-12.67");
    [self assert:CPCalculationNoError equals:SIDecimalSubtract(d1,d2,d3,CPRoundPlain) message:"SIDecimalSubtract(): Ts4: Should succeed"];
    [self assert:-3 equals:d1._exponent message:"SIDecimalSubtract(): Ts4: exponent"];
    [self assert:[1,3,5,4,5] equals:d1._mantissa message:"SIDecimalSubtract(): Ts4: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalSubtract(): Ts4: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalSubtract(): Ts4: NaN is incorrectly set"];

    // loss of precision
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"1e-128");
    d3 = SIDecimalMakeWithString(@"1");
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalSubtract(d1,d2,d3,CPRoundPlain) message:"SIDecimalSubtract(): Tsp1: Should throw loss of precision"];
    [self assert:0 equals:d1._exponent message:"SIDecimalSubtract(): Tsp1: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalSubtract(): Tsp1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalSubtract(): Tsp1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalSubtract(): Tsp1: NaN is incorrectly set"];
}

- (void)testDivide
{
    var d1 = SIDecimalMakeZero();
    var d2 = SIDecimalMakeWithString(@"55e12");
    var d3 = SIDecimalMakeWithString(@"-5e20");
    [self assert:CPCalculationNoError equals:SIDecimalDivide(d1,d2,d3,CPRoundPlain) message:"SIDecimalDivide(): Td1: Should succeed"];
    [self assert:-8 equals:d1._exponent message:"SIDecimalDivide(): Td1: exponent"];
    [self assert:[1,1] equals:d1._mantissa message:"SIDecimalDivide(): Td1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalDivide(): Td1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalDivide(): Td1: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-1e12");
    d3 = SIDecimalMakeWithString(@"-1e6");
    [self assert:CPCalculationNoError equals:SIDecimalDivide(d1,d2,d3,CPRoundPlain) message:"SIDecimalDivide(): Td2: Should succeed"];
    [self assert:6 equals:d1._exponent message:"SIDecimalDivide(): Td2: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalDivide(): Td2: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalDivide(): Td2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalDivide(): Td2: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"1");
    d3 = SIDecimalMakeWithString(@"0.00001");
    [self assert:CPCalculationNoError equals:SIDecimalDivide(d1,d2,d3,CPRoundPlain) message:"SIDecimalDivide(): Td3: Should succeed"];
    [self assert:5 equals:d1._exponent message:"SIDecimalDivide(): Td3: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalDivide(): Td3: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalDivide(): Td3: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalDivide(): Td3: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"1");
    d3 = SIDecimalMakeWithString(@"3");
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalDivide(d1,d2,d3,CPRoundPlain) message:"SIDecimalDivide(): Tdp1: Should Loss of precision"];
    [self assert:-38 equals:d1._exponent message:"SIDecimalDivide(): Tdp1: exponent"];
    [self assert:[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3] equals:d1._mantissa message:"SIDecimalDivide(): Tdp1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalDivide(): Tdp1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalDivide(): Tdp1: NaN is incorrectly set"];

    // Why doesnt Cocoa round the final digit up?
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-0.875");
    d3 = SIDecimalMakeWithString(@"12");
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalDivide(d1,d2,d3,CPRoundUp) message:"SIDecimalDivide(): Tdp2: Should Loss of precision"];
    [self assert:-39 equals:d1._exponent message:"SIDecimalDivide(): Td2: exponent"];
    [self assert:[7,2,9,1,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6] equals:d1._mantissa message:"SIDecimalDivide(): Td2: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalDivide(): Td2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalDivide(): Td2: NaN is incorrectly set"];

    // div zero
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-0.875");
    d3 = SIDecimalMakeWithString(@"0");
    [self assert:CPCalculationDivideByZero equals:SIDecimalDivide(d1,d2,d3,CPRoundUp) message:"SIDecimalDivide(): Tdp2: Should Loss of precision"];
}

- (void)testMultiply
{
    var d1 = SIDecimalMakeZero();
    var d2 = SIDecimalMakeWithString(@"12");
    var d3 = SIDecimalMakeWithString(@"-1441231251321235231");
    [self assert:CPCalculationNoError equals:SIDecimalMultiply(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiply(): Tm1: Should succeed"];
    [self assert:0 equals:d1._exponent message:"SIDecimalMultiply(): Tm1: exponent"];
    [self assert:[1,7,2,9,4,7,7,5,0,1,5,8,5,4,8,2,2,7,7,2] equals:d1._mantissa message:"SIDecimalMultiply(): Tm1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalMultiply(): Tm1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiply(): Tm1: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"23e100");
    d3 = SIDecimalMakeWithString(@"-13e-76");
    [self assert:CPCalculationNoError equals:SIDecimalMultiply(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiply(): Tm2: Should succeed"];
    [self assert:24 equals:d1._exponent message:"SIDecimalMultiply(): Tm2: exponent"];
    [self assert:[2,9,9] equals:d1._mantissa message:"SIDecimalMultiply(): Tm2: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalMultiply(): Tm2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiply(): Tm2: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-0.8888");
    d3 = SIDecimalMakeWithString(@"8.88e2");
    [self assert:CPCalculationNoError equals:SIDecimalMultiply(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiply(): Tm3: Should succeed"];
    [self assert:-4 equals:d1._exponent message:"SIDecimalMultiply(): Tm3: exponent"];
    [self assert:[7,8,9,2,5,4,4] equals:d1._mantissa message:"SIDecimalMultiply(): Tm3: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalMultiply(): Tm3: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiply(): Tm3: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"-1e111");
    d3 = SIDecimalMakeWithString(@"-1e-120");
    [self assert:CPCalculationNoError equals:SIDecimalMultiply(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiply(): Tm4: Should succeed"];
    [self assert:-9 equals:d1._exponent message:"SIDecimalMultiply(): Tm4: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalMultiply(): Tm4: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalMultiply(): Tm4: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiply(): Tm4: NaN is incorrectly set"];

    // loss of precision
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"212341251123892374823742638472481124");
    d3 = SIDecimalMakeWithString(@"127889465810478913");
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalMultiply(d1,d2,d3,CPRoundDown) message:"SIDecimalMultiply(): Tmp1: Should throw loss of precision"];
    [self assert:15 equals:d1._exponent message:"SIDecimalMultiply(): Tmp1: exponent"]; // 69 diff
    [self assert:[2,7,1,5,6,2,0,9,1,7,5,7,6,3,3,5,0,9,2,9,7,4,0,2,3,5,6,0,8,0,6,9,5,2,8,3,9,1] equals:d1._mantissa message:"SIDecimalMultiply(): Tmp1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalMultiply(): Tmp1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiply(): Tmp1: NaN is incorrectly set"];

    // overflow
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"1e110");
    d3 = SIDecimalMakeWithString(@"1e111");
    [self assert:CPCalculationOverflow equals:SIDecimalMultiply(d1,d2,d3,CPRoundDown) message:"SIDecimalMultiply(): Tmo1: Should throw overflow"];
    [self assert:YES equals:d1._isNaN message:"SIDecimalMultiply(): Tmo1: NaN is incorrectly set"];
}

// Power is unsigned
- (void)testPower
{
    var d1 = SIDecimalMakeZero();
    var d2 = SIDecimalMakeWithString(@"123");
    var d3 = 12;
    [self assert:CPCalculationNoError equals:SIDecimalPower(d1,d2,d3,CPRoundPlain) message:"SIDecimalPower(): Tp1: Should succeed"];
    [self assert:0 equals:d1._exponent message:"SIDecimalPower(): Tp1: exponent"];
    [self assert:[1,1,9,9,1,1,6,3,8,4,8,7,1,6,9,0,6,2,9,7,0,7,2,7,2,1] equals:d1._mantissa message:"SIDecimalPower(): Tp1: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalPower(): Tp1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalPower(): Tp1: NaN is incorrectly set"];

    //0.00000 13893554059925661274821814636807535200 1 cocoa (39 digits)
    //0.00000 13893554059925661274821814636807535204 This , a few off
    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"0.875");
    d3 = 101;
    [self assert:CPCalculationLossOfPrecision equals:SIDecimalPower(d1,d2,d3,CPRoundUp) message:"SIDecimalPower(): Tp2: Should throw Loss of precision"];
    [self assert:-43 equals:d1._exponent message:"SIDecimalPower(): Tp2: exponent"];
    [self assert:[1,3,8,9,3,5,5,4,0,5,9,9,2,5,6,6,1,2,7,4,8,2,1,8,1,4,6,3,6,8,0,7,5,3,5,2,0,4] equals:d1._mantissa message:"SIDecimalPower(): Tp2: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalPower(): Tp2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalPower(): Tp2: NaN is incorrectly set"];

}

- (void)testPower10
{
    var d1 = SIDecimalMakeZero();
    var d2 = SIDecimalMakeWithString(@"-0.875");
    var d3 = 3;
    [self assert:CPCalculationNoError equals:SIDecimalMultiplyByPowerOf10(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiplyByPowerOf10(): Tpp1: Should succeed"];
    [self assert:0 equals:d1._exponent message:"SIDecimalMultiplyByPowerOf10(): Tpp1: exponent"];
    [self assert:[8,7,5] equals:d1._mantissa message:"SIDecimalMultiplyByPowerOf10(): Tpp1: mantissa"];
    [self assert:YES equals:d1._isNegative message:"SIDecimalMultiplyByPowerOf10(): Tpp1: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiplyByPowerOf10(): Tpp1: NaN is incorrectly set"];

    d1 = SIDecimalMakeZero();
    d2 = SIDecimalMakeWithString(@"1e-120");
    d3 = 130;
    [self assert:CPCalculationNoError equals:SIDecimalMultiplyByPowerOf10(d1,d2,d3,CPRoundPlain) message:"SIDecimalMultiplyByPowerOf10(): Tpp2: Should succeed"];
    [self assert:10 equals:d1._exponent message:"SIDecimalMultiplyByPowerOf10(): Tpp2: exponent"];
    [self assert:[1] equals:d1._mantissa message:"SIDecimalMultiplyByPowerOf10(): Tpp2: mantissa"];
    [self assert:NO equals:d1._isNegative message:"SIDecimalMultiplyByPowerOf10(): Tpp2: sign"];
    [self assert:NO equals:d1._isNaN message:"SIDecimalMultiplyByPowerOf10(): Tpp2: NaN is incorrectly set"];
}

- (void)testString
{
    var dcm = SIDecimalMakeWithString(@"0.00123");
    [self assert:"0.00123" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts1"];
    dcm = SIDecimalMakeWithString(@"2e3");
    [self assert:"2000" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts2"];
    dcm = SIDecimalMakeWithString(@"0.00876e-5");
    [self assert:"0.0000000876" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts3"];
    dcm = SIDecimalMakeWithString(@"98.56e10");
    [self assert:"985600000000" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts4"];
    dcm = SIDecimalMakeWithString(@"-1e-1");
    [self assert:"-0.1" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts5"];
    dcm = SIDecimalMakeWithString(@"-5e20");
    [self assert:"-500000000000000000000" equals:SIDecimalString(dcm,nil) message:"SIDecimalString() Ts6"];
}

@end
