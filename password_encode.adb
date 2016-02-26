with Ada.Strings,
     Ada.Strings.UTF_Encoding,
     Ada.Strings.UTF_Encoding.Wide_Strings,
     Ada.Wide_Text_IO;
use Ada.Strings.UTF_Encoding;

package body Password_Encode is

   package body IO is
      use Ada.Sequential_IO;
      use Ada.Sequential_IO.C_Streams;
   begin
      null;
   end;
   --
   --
   package body Base64 is

      --
      procedure Decode(Source  : in     String;
                       Target  :    out Bytes;
                       Last    :    out Natural) is
         -- Six-bit value representing a Base64 character's numerical value.
         D       : Six_Bits;
         -- Slot := which chunk of bits in a 24-bit segment is being represented
         -- by the current character or value of D.  range:  0 .. 3
         type Slots is mod 4;
         Slot    : Slots := 0;
         -- Current operation's string index of input string.

      begin
         Last := Target'first - 1;
         for Si in Source'range loop
            D := To_ModSix(Source(Si));
            if D /= 0 or else Source(Si) = 'A' then
               -- source is valid Base64
               case Slot is
               when 0 =>
                  Last := Last + 1;
                  Target(Last) := 4 * D;            -- dddddd00 ........ ........
               when 1 =>
                  Target(Last) := Target(Last) + D / 16;
                  exit when Last = Target'last
                    and then (Si = Source'last or else Source(Si + 1) = '=')
                    and then (D mod 16) = 0;
                  Last := Last + 1;
                  Target(Last) := (D mod 16) * 16;  -- dddddddd dddd0000 ........
               when 2 =>
                  Target(Last) := Target(Last) + D / 4;
                  exit when Last = Target'last
                    and then (Si = Source'last or else Source(Si + 1) = '=')
                    and then (D mod 4) = 0;
                  Last := Last + 1;
                  Target(Last) := (D mod 4) * 64;   -- dddddddd dddddddd dd000000
               when 3 =>
                  Target(Last) := Target(Last) + D; -- dddddddd dddddddd dddddddd
               end case;
               Slot := Slot + 1;
            elsif Source(Si) = '=' then
               exit; -- terminator encountered
            end if; -- silently ignore whitespace, lf, garbage, ...
         end loop;
      end Decode;
      function Decode(Source : in String) return Bytes is
         Out_Bytes : Bytes(1 .. Source'Length) := (others => 0);
         Out_Length : Natural := 0;
      begin
         Decode(Source, Out_Bytes, Out_Length);
         return Out_Bytes(1 .. Out_Length);
      end Decode;

      -- Encode Bytes into Base64 String.
      procedure Encode(Source  : in     Bytes;
                       Target  :    out String;
                       Last    :    out Natural) is
         -- Target is filled in four character increments, except that
         -- a CR-LF pair is inserted after every 76 characters.
         -- Target'length must be at least:
         -- Output_Quad_Count: constant := (Source'length + 2) / 3;
         -- Output_Byte_Count: constant := 4 * Output_Quad_Count;
         -- Target'length = Output_Byte_Count + 2 * (Output_Byte_Count / 76)
         -- Constraint_Error will be raised if Target isn't long enough.
         --         use type Ada.Streams.Stream_Element;
         --         use type Ada.Streams.Stream_Element_Offset;
         D       : Six_Bits;
         type Slots is mod 3;
         Slot    : Slots := 0;
         Output_Line_Length: Natural := 0;
      begin
         Last := Target'first - 1;
         for Si in Source'range loop
            case Slot is
            when 0 =>
               Output_Line_Length := Output_Line_Length + 4;
               Last := Last + 4;
               Target(Last - 3) := To_Char64(Source(Si) / 4);
               D := (Source(Si) mod 4) * 16;
               Target(Last - 2) := To_Char64(D);
               Target(Last - 1) := '=';
               Target(Last) := '=';
               -- dddddd dd0000  = =
            when 1 =>
               D := D + Source(Si) / 16;
               Target(Last - 2) := To_Char64(D);
               D := (Source(Si) mod 16) * 4;
               Target(Last - 1) := To_Char64(D);
               -- dddddd dddddd dddd00 =
            when 2 =>
               D := D + Source(Si) / 64;
               Target(Last - 1) := To_Char64(D);
               Target(Last) := To_Char64(Source(Si) mod 64);
               -- dddddd dddddd dddddd dddddd
            end case;
            Slot := Slot + 1;
         end loop;
      end Encode;
      function Encode(Source : in Bytes) return String is
         Out_String : String(1 .. (((Source'Length * 4) / 3) + 4));
         Out_Length : Natural := 0;
      begin
         Encode(Source, Out_String, Out_Length);
         return Out_String(1 .. Out_Length);
      end Encode;

   end Base64;
   --
   --

   --
   --
   function Standard_Input  return IO.File_Type is
      File_Handle : IO.File_Type;
   begin
      IO.C_Streams.Open(
                        File =>
                          File_Handle,
                        Mode =>
                          IO.In_File,
                        C_Stream =>
                          IO.C_Streams.ICS.stdin);
      return File_Handle;
   end Standard_Input;
   function Standard_Output return IO.File_Type is
      File_Handle : IO.File_Type;
   begin
      IO.C_Streams.Open(
                        File =>
                          File_Handle,
                        Mode =>
                          IO.Out_File,
                        C_Stream =>
                          IO.C_Streams.ICS.stdout);
      return File_Handle;
   end Standard_Output;
   --
   --
   function Get_Codec return Password_Codec is
      New_Codec : Password_Codec := Codec;
   begin
      if Codec = Password_Codec'Last
      then Codec := Password_Codec'First;
      else Codec := Password_Codec'Succ(Codec);
      end if;
      return New_Codec;
   end Get_Codec;
   --
   --
   procedure Report_Wide(Message: Wide_String) is
   begin
      Ada.Wide_Text_IO.Put_Line(File => Ada.Wide_Text_IO.Current_Error,
                                Item => Message);
   end Report_Wide;
   procedure Report(Message : UTF_8_String) is
      Converted_String : Wide_String := Wide_Strings.Decode(Item => Message);
   begin
      Report_Wide(Message => Converted_String);
   end Report;

   --
   --
   protected body Encoder_Module is

      procedure Get_Next(Target : out Natural) is
      begin
         Target   := Natural(Data(Position));
         Position := (Position mod Finish) + 1;
      end Get_Next;
      procedure Get_Next(Target : out Natural; Increment : Boolean) is
      begin
         Target   := Natural(Data(Position) + Inc);
         Inc      := (Inc + 1) mod 65536;
         Position := (Position mod Finish) + 1;
      end Get_Next;

      function Codec return Password_Codec is
      begin
         return Module_Codec;
      end Codec;

      procedure Set(S : in Wide_String := " ") is
         C : Wide_Character;
         function Validate(Character_Pos : Natural) return Offset is
            Valid_Offset: Offset := 0;
         begin
            if Character_Pos > 31
            then
               Valid_Offset := Offset(Character_Pos - 31);
            else
               Valid_Offset := 0;
            end if;
            return Valid_Offset;
         end Validate;
      begin
         if S'Length < Size
         then
            Finish := S'Length;
         else
            Finish := Size;
            Report("Warning: password is as large or larger than allowed by this program.");
            Report(" To decrypt later you must use the exact same program or one with exact same");
            Report(" internal configuration -- must clip the length of password to the same length");
            Report(" as is being done now.");
         end if;
         Is_Set := True;
         for Position in 1 .. Finish loop
            C := S(Position);
            Data(Position) := Validate(Wide_Character'Pos(C));
         end loop;
         Module_Codec := Get_Codec;
         Position := 1;
      end Set;

      function Status return Boolean is
      begin
         return Is_Set;
      end Status;

      procedure Reset is
      begin
         Position := 1;
         Inc := 0;
      end Reset;

   end Encoder_Module;


   --
   -- Make a new encoder for every File Input/Output to be performed within
   -- any given time -- only one for One file at a time using the same
   -- password set.
   protected body Encoder is

      function Status return Integer is
         Number : Integer := 0;
      begin
         if Data(Status_Count).Status = True
         then
            Number := Status_Count;
         else
            for Module in Data'Range loop
               if Data(Module).Status
               then
                  Number := Number + 1;
               end if;
            end loop;
         end if;
         return Number;
      end Status;

      procedure Reset is
      begin
         for Module in Data'Range loop
            Data(Module).Reset;
         end loop;
         Is_Clean := True;
      end Reset;

      procedure Set_Wide(S : in Wide_String) is
      begin
         if Status < Data'Length
         then
            Data(Status + 1).Set(S);
         end if;
      end Set_Wide;
      --
      procedure Set(S : in UTF_8_String) is
         NewData : Wide_String := Wide_Strings.Decode(Item=> S);
      begin
         Set_Wide(S => NewData);
      end Set;
      --
      procedure Set is
         NewData : Wide_String(1 .. 1) := (others => Ada.Strings.Wide_Space);
      begin
         Set_Wide(S => NewData);
      end Set;

      procedure Encode(Input : in Bytes; Output : out Bytes) is
         Input_Data : String := Base64.Encode(Input);
         Input_Length : Integer := Input_Mod'Length;
         Modules : constant Integer := Status;
         Bytes_Length : Integer := Input'Length;
         Break_Point : Integer := 1;
         Output_Data : String(1 .. Input_Length) := Input_Data;
      begin
         for Module in Data'Range loop
            case Data(Module).Codec is

            when Modular =>
               if Bytes_Length mod 3 = 0
               then
                  for N in 1 .. Input_Length loop
                     Output_Mod(N) :=
                       Base64.To_Char64((Base64.To_ModSix(Input_Data(N))
                         + Data(Module).Get_Next) mod 64);
                  end loop;
               else
                  for N in 1 .. (Input_Length - 4) loop
                     Output_Mod(N) :=
                       Base64.To_Char64((Base64.To_ModSix(Input_Mod(N))
                         + GetNext) mod 64);
                  end loop;
                  for N in (Input_Length - 4) .. (Input_Length - 1) loop
                     if Input_Mod(N + 1) = '='
                     then
                        Output_Mod(N) := Input_Mod(N);
                     else
                        Output_Mod(N) :=
                          Base64.To_Char64((Base64.To_ModSix(Input_Mod(N)) + GetNext) mod 64);
                     end if;
                  end loop;
               end if;
               when Low_Swap =>
                  null;
               when Incrementing =>
                  null;
               when High_Swap =>
                  null;
            end case;
         end loop;
         if Is_Set2
         then
            Input_Mod2 := Output_Mod;
            if Bytes_Length mod 3 = 0
            then
               Break_Point := Input_Length / 2;
            else
               Break_Point := (Input_Length - 4) / 2;
            end if;
            for N in GetNext2 loop
               N := (Data(Module).Get_Next mod Break_Point) + 1;
               for M in 1 .. N loop
                  Output_Mod(M) := Input_Mod2(M + N);
                  Output_Mod(M + N) := Input_Mod2(M);
               end loop;
            end loop;
         end if;
         if Is_Set3
         then
            null;
         end if;
         if Bytes_Length < 57
         then
            Is_Clean := False;
         end if;
      end Encode;

   end Encoder;

end Password_Encode;
