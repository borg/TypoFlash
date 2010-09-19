/**
* Binomial.as - Generate Binomial coefficients, either individually or as a single row in Pascal's triangle
*
* Copyright (c) 2007, Jim Armstrong.  All rights reserved.
*
* This software program is supplied 'as is' without any warranty, express, 
* implied, or otherwise, including without limitation all warranties of 
* merchantability or fitness for a particular purpose.  Jim Armstrong shall not 
* be liable for any special incidental, or consequential damages, including, 
* witout limitation, lost revenues, lost profits, or loss of prospective 
* economic advantage, resulting from the use or misuse of this software program.
*
* @author Jim Armstrong, Singularity (www.algorithmist.net)
*
* @version 1.0
*/
package Singularity.Numeric
{
  public class Binomial
  {
    // core
    private var __row:Array;                // currently generated row (nonsymmetric portion)
    private var __n:uint;                 // row number or 'n' in binomial coefficient (n k)
  
    public function Binomial()
    {
      __n   = 2;
      __row = [1,2];
    }

/**
* @description coef( _n:uint, _k:uint ) - Generate the binomial coefficient (n k)
*
* @param _n:uint - n items
* @param _k:Numer  - k at a time
*
* @since 1.0
*
* @return Number: Binomial coefficient (n k)
*
*/
    public function coef( _n:uint, _k:uint ):uint   
    {
      if( _k > _n )
        return 0;
      else if( _k == _n )
        return 1;
        
      if( __n != _n )
        __recurse(_n);

      var j:uint = __n % 2;
      var e:uint = (__n+2-j)/2;

      return (_k>=e) ? __row[_n-_k] : __row[_k];
    }

/**
* @description getRow( _n:uint ) - Return the n-th full row of Pascal's triangle
*
* @param _n:uint - Index of desired row (beginning at zero)
*
* @since 1.0
*
* @return Array: Full n-th row of Pascal's triangle
*
* Note:  It is the caller's responsibility to delete the returned array if calling this method more than once
*
*/
    public function getRow(_n:uint):Array  
    { 
      switch(_n)
      {
        case 0:
          return [1];
        break;

        case 1:
          return [1,1];
        break;

        case 2:
          return [1,2,1];
        break;

        default:
          var newRow:Array = ( _n == __n ) ? __fillOut() : __recurse(_n);
          return newRow;
        break;
      }
    }

    // fill out nonsymmetric portion of current row, returning reference to full array
    private function __fillOut():Array
    {
      var j:uint    = __n % 2;
      var e:uint    = (__n+2-j)/2;
      var arr:Array = __row.slice(0,e+1);

      if( j == 0 )
      {
        for( var i:uint=0; i<e-1; ++i )
          arr[e+i] = arr[e-i-2];
      }
      else
      {
        for( i=0; i<e; ++i )
          arr[e+i] = arr[e-i-1];
      }

      return arr;
    }

    // recursively generate desired row from the current row
    private function __recurse(_r:uint):Array
    {
      // forward or reverse?
      if( _r > __n )
        __forward(_r);
      else
      {
        // recurse backward or reset and move forward ... inquiring minds want to know :)
        if( (_r-2) <= (__n-_r) )
        {
          // reset and move forward
          __row[1] = 2;
          __n      = 2;
          __forward(_r);
        }
        else
          __reverse(_r);
      }

      __n = _r;
      return __fillOut(); 
    }

    // run recursion forward
    private function __forward(_r:uint):void
    {
      for( var i:uint=__n+1; i<=_r; ++i )
      {
        // how many elements in the nonsymmetric portion of the current row?
        var j:uint = i % 2;
        var e:uint = (i+2-j)/2;
        var h:uint = __row[0];

        if( j == 1 ) 
        { 
          for( var k:uint=1; k<e; ++k )
          {
            var val:uint = __row[k] + h;
            h              = __row[k];
            __row[k]       = val;
          }
        }
        else
        {
          for( k=1; k<e-1; ++k )
          {
            val      = __row[k] + h;
            h        = __row[k];
            __row[k] = val;
          }
          __row[e-1] = 2*h;
        }
      }
    }

    // run recursion backwards
    private function __reverse(_r:uint):void
    {
      for( var i:uint=__n-1; i>=_r; i-- )
      {
        // how many elements in the nonsymmetric portion of the current row?
        var j:uint = i % 2;
        var e:uint = (i+2-j)/2;

        for( var k:uint=1; k<e; ++k )
          __row[k] = __row[k] - __row[k-1];
      }
    }
  }
}