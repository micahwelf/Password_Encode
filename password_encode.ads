with Ada.Strings.UTF_Encoding,
     Ada.Sequential_IO,
     Interfaces.C_Streams,
     Ada.Sequential_IO.C_Streams;
use Ada.Strings.UTF_Encoding;

-- Library to Encrypt raw data with variable length UTF8 Passwords, making
-- it possible to simply memorize the Passwords as a poem or as random-
-- length stored keys.  zero to three Passwords may be specified.  If none,
-- then a default built in key is used for the encryption, but the longer
-- and more Passwords their are the more impossible the encryption becomes
-- to break.
package Password_Encode is

   type Byte is mod 2**8;
   for Byte'Size use 8;
   subtype Byte_Index is Integer range 1..57;
   type Bytes is array(Byte_Index range <>) of Byte;
   type Offset is mod 2**64;
   for Offset'Size use 64;
   type Offsets is array(Positive range <>) of Offset;
   -- **Modular codec is the primary codec that simply adds to the value of
   -- a six-bit unit, wrapping to zero again. **Low_Swap swaps two consecutive
   -- chunks starting at the beginning of the 76 six-bit units in a block.
   -- **Incrementing is Modular, but every call to it's value Increments to a
   -- higher value than it would have -- increasing seeming randomness in the
   -- encoded bits. **High_Swap is Low_Swap, but on the end of the block.
   type Password_Codec is (Modular, Low_Swap, Incrementing, High_Swap);

   package IO is new Ada.Sequential_IO(Byte);
   use IO;

   -- Base64 encode/decode & test driver.
   -- Copyright 2001 Tom Moran (tmoran@acm.org, PGP signed tmoran@bix.com),
   -- anyone may use for any purpose.
   -- RFC 1521, MIME Base64 encode/decode
   -- Modified by Micah Waddoups (makesharp.net) 2016.
   package Base64 is

      -- Appropriate range for the index of possible Base64 charaters/values.
      subtype Six_Bits is Byte range 0 .. 63;

      -- Take any Base64 Character and return it's Base64 modulus six value.
      To_ModSix: constant array (Character) of Six_Bits
        := ('A' => 0,'B' => 1,'C' => 2,'D' => 3,'E' => 4,'F' => 5,'G' => 6,
            'H' => 7,'I' => 8,'J' => 9,'K' =>10,'L' =>11,'M' =>12,'N' =>13,
            'O' =>14,'P' =>15,'Q' =>16,'R' =>17,'S' =>18,'T' =>19,'U' =>20,
            'V' =>21,'W' =>22,'X' =>23,'Y' =>24,'Z' =>25,'a' =>26,'b' =>27,
            'c' =>28,'d' =>29,'e' =>30,'f' =>31,'g' =>32,'h' =>33,'i' =>34,
            'j' =>35,'k' =>36,'l' =>37,'m' =>38,'n' =>39,'o' =>40,'p' =>41,
            'q' =>42,'r' =>43,'s' =>44,'t' =>45,'u' =>46,'v' =>47,'w' =>48,
            'x' =>49,'y' =>50,'z' =>51,'0' =>52,'1' =>53,'2' =>54,'3' =>55,
            '4' =>56,'5' =>57,'6' =>58,'7' =>59,'8' =>60,'9' =>61,'+' =>62,
            '/' =>63,
            others => 0);

      -- Take any modulus six (6-bit) number and return it's Base64 Character.
      To_Char64: constant array (Six_Bits) of Character
        := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

      --
      -- decode Source into Target(Target'first .. Last)
      -- Note: it may be appropriate to prescan Source for '='
      procedure Decode(
                       -- Base64 String to by converted into Bytes
                       Source  : in     String;
                       -- Variable to hold output Bytes.
                       Target  :    out Bytes;
                       -- Variable to put actual NUMBER of created bytes (Bytes
                       -- output buffer may be larger than what Base64 String stores).
                       Last    :    out Natural);
      --
      -- decode Source and return Bytes.
      -- Note: it may be appropriate to prescan Source for '='
      function Decode(Source : in String) return Bytes;

      --
      -- Target is filled in four character increments.
      -- Target'length must be at least:  (4/3) * Source'length;  AND   modulus 4
      procedure Encode(Source  : in     Bytes;
                       Target  :    out String;
                       Last    :    out Natural);
      function Encode(Source : in Bytes) return String;

   end Base64;
   --
   --

   -- Standard In and Out for command-pipe encoding.
   function Standard_Input  return IO.File_Type;
   function Standard_Output return IO.File_Type;

   -- The next Encoder_Module created is to use this as it's codec, then bump
   -- this value to the Password_Codec'Succ, wrapping around, for as many
   -- Password_Modules as will be created.
   Codec : Password_Codec := Modular;
   function Get_Codec return Password_Codec;

   -- Print line of text to standard output. (16-bit String, International)
   procedure Report_Wide(Message: Wide_String);
   -- Print line of text to standard output. (8-bit UTF String, International)
   procedure Report(Message: UTF_8_String);

   -- Encryption Key which pulls an appropriate value each time it is accessed.
   -- Used by Encoder.
   protected type Encoder_Module (
                                  -- How many characters/units in this Encoder_Module.
                                  Size: Positive := 8**4) is
      -- Assign out the next value, looping the length of this Encoder_Module.
      -- The Increment is just a way to efficiently get an incrementing value.
      procedure Get_Next(Target : out Natural);
      procedure Get_Next(Target : out Natural; Increment : Boolean);

      -- Codec associated with this Encoder_Module.
      function Codec return Password_Codec;

      -- Assign the values by the derived value of each character in S.
      procedure Set(S : in Wide_String := " ");

      -- Return whether the Module has been assign to.
      function Status return Boolean;

      -- Reset Module to initial, just-set state for re-use on another file or stream.
      procedure Reset;

   private
      --         Banks of values that will be used during encoding/decoding.
      Data         : Offsets (1 .. Size) := (1 => 1, others => 0);
      --  Whether assignment has been made to this module. Initial is False.
      Is_Set       : Boolean := False;
      --                                    Current cell to pull value from.
      Position     : Positive := 1;
      --                                                 Incrementing value.
      Inc          : Offset := 0;
      --                          The Codec used when pulling from this key.
      Module_Codec : Password_Codec := Modular;
      --                     Position of last offset from first (1..Finish).
      Finish       : Positive := 1;
      --                    Holding space for security measure decoy blocks.
      Start        : Positive := 1; --
      --                         Necessary link incase future use as a List.
      Next         : access Encoder_Module;
   end Encoder_Module;

   -- Collection of encryption keys.
   type Encoder_Matrix is array(Positive range <>) of Encoder_Module;

   -- Make a new encoder for every File Input/Output to be performed within
   -- any given time -- only one for One file at a time using the same
   -- password set.
   protected type Encoder (
                           -- The number of Encoder_Modules (password/key's) in
                           -- this Encoder.
                           Size : Positive := 1;
                           -- The maximum number of character/units allowed in
                           -- any password/key.
                           Max_Key_Size : Positive := 8**4) is

      -- Simply return how many passwords have been set.
      function Status return Integer;

      -- Reset password data to its state just after being assigned, and
      -- unlock the encoder or decoder.
      procedure Reset;

      -- Assign a Wide_String or UTF_8_String value to the Password.
      -- Each assignment defines the first unassigned password/key
      -- in a series of three. Further assignments do nothing.
      procedure Set_Wide (S : in Wide_String);
      procedure Set (S : in UTF_8_String);
      procedure Set;

      -- Using this Encoder (or set of passwords), encode the given input bytes,
      -- File_Type, or Filename. !! Only the exact same set of passwords will be
      -- able to recover the data after it has been encoded.
      procedure Encode(Input : in Bytes; Output : out Bytes);
      procedure Encode(Input : in IO.File_Type; Output : out IO.File_Type);
      procedure Encode(In_Filename : in String; Out_Filename : out String);

   private


      -- Data is the raw buffer space in which the Password is held.

      Data  : Encoder_Matrix(1 .. Size);
      Status_Count : Natural := 0;

      -- Signals whether the Password has been set with a set() instruction.
      Is_Set  : Boolean := False;
      Is_Set2 : Boolean := False;
      Is_Set3 : Boolean := False;

      -- Sygnals whether An incomplete block of Bytes has been encountered
      -- while encoding (less than 57 Bytes).  If it has, then require a Reset
      -- to be run before anything more can be coded.  This is to prevent data
      -- curruption, and is a modest precaution.
      Is_Clean : Boolean := True;

      -- Start, Finish, and current_position control where in the Password
      -- buffer the Wide_String is and which Wide_Character to pull from
      -- it next.
      Start, Current_Position   : Positive := 1;
      Finish                    : Natural := 0;
      Start2, Current_Position2 : Positive := 1;
      Finish2                   : Natural := 0;
      Start3, Current_Position3 : Positive := 1;
      Finish3                   : Natural := 0;
   end Encoder;


end Password_Encode;
