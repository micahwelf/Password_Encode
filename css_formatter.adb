with Ada;                      use Ada;
with Ada.Text_IO;
with Ada.Text_IO.Text_Streams; use Ada.Text_IO.Text_Streams;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Command_Line;
with Ada.Characters.Latin_1;   use Ada.Characters.Latin_1;
with Ada.Strings.Fixed;        use Ada.Strings.Fixed;
with Ada.Containers.Indefinite_Holders;
with Ada.Containers.Indefinite_Vectors;
with GNAT.Regpat;

procedure Css_Formatter is

   function Current_Input return Text_IO.File_Type is
   begin
      return Ada.Text_IO.Current_Input;
   end Current_Input;

   function Current_Output return Text_IO.File_Type is
   begin
      return Ada.Text_IO.Current_Output;
   end Current_Output;

   package Text_Holder is new Ada.Containers.Indefinite_Holders (String);
   use Text_Holder;

   package Text_Vector is new Ada.Containers.Indefinite_Vectors
     (Positive,
      Character);

   package Regex renames GNAT.Regpat;
   use Regex;

   procedure Put_Line (Text : in Holder) is
   begin
      Text_IO.Put_Line (Current_Output, Text.Element);
   end Put_Line;

   procedure Get_Line (Text : in out Holder) is
   begin
      Text.Assign (To_Holder (Text_IO.Get_Line (Current_Input)));
   end Get_Line;

   function Argument (Number : Positive) return String is
   begin
      if Number <= Command_Line.Argument_Count then
         return Command_Line.Argument (Number => Number);
      else
         return "";
      end if;
   end Argument;

   File_Too_Big : exception;
   Malformed_CSS : exception;

   Subject_File : Text_IO.File_Type;

   Text : String (1 .. 1_000_000) := (others => Space);

   First : Positive := 1;
   Last  : Natural  := 0;

   Index : Positive := 1;
   Count : Natural  := 0;

   Indent : Natural := 0;

   Not_Empty : Boolean := False;

   procedure Read_File is
   begin
      loop
         if Last < Text'Last then
            Last := Last + 1;
            Character'Read (Stream (Subject_File), Text (Last));
         else
            raise File_Too_Big;
         end if;
         exit when Text_IO.End_Of_File;
      end loop;
   end Read_File;

   function Matched
     (Match : Regex.Match_Location :=
        (First => 1, Last => 0))
      return String
   is
   begin
      return Text (Match.First .. Match.Last);
   end Matched;

--     Selector_Pattern : String :=
--       "\s*?((?:@?[a-zA-Z.#>~_-]|[[](?:"".*?""|.*?)[]]|\s*?|[(](?:[(](?:[(].*?[)]|.)*?[)]|.)*?[)])*?)\s*?";
   Selector_Pattern : String :=
     "\s*?((?:@?[a-zA-Z.#>~_-]|[[](?:"".*?""|.*?)[]]|\s*?|[(](?:[(](?:[(].*?[)]|.)*?[)]|.)*?[)])*?)\s*?";

--     Property_Pattern : String := "\s*?((?:[][a-zA-Z-])*)\s*?";
   Property_Pattern : String := "\s*?((?:[][a-zA-Z-])*)\s*?";

--     Value_Pattern    : String :=
--       "\s*?((?:[a-z]+[(].*?[)]|[a-zA-Z0-9.-]*?|"".*?""|\s*?)*)\s*?";
   Value_Pattern : String :=
     "\s*?((?:[a-z]+[(].*?[)]|[a-zA-Z0-9.-]*?|"".*?""|\s*?)*)\s*?";

   Matches : Regex.Match_Array (0 .. 4);

   Flags : Regex.Regexp_Flags :=
     Regex.Case_Insensitive + Regex.Single_Line + Regex.Multiple_Lines;

   Selector_Open : Regex.Pattern_Matcher :=
     Regex.Compile ("^\s*" & Selector_Pattern & "\s*({)", Flags);

   Selector_Close : Regex.Pattern_Matcher :=
     Regex.Compile ("^\s*(})\s*", Flags);

   Declaration : Regex.Pattern_Matcher :=
     Regex.Compile
       ("\s*" & Property_Pattern & "^\s*:\s*" & Value_Pattern & "\s*;",
        Flags);

   function Parse_Open return Boolean is
      Matches : Regex.Match_Array (0 .. 2);
   begin
      Regex.Match (Selector_Open, Text (First .. Last), Matches, Index);

      if Regex.Match (Selector_Open, Text (First .. Last), Index)
      then
        --Matched (Matches (1)) /= "" and then Matched (Matches (2)) /= "";
         String'Write
           (Stream (Current_Output),
            (Indent * HT) & Matched (Matches (1)) & " {" & LF);
         Indent := Indent + 1;
         Index  := Matches (0).Last + 1;
         return True;
      else
         return False;
      end if;
   end Parse_Open;

   function Parse_Declaration return Boolean is
      Matches : Regex.Match_Array (0 .. 2);
   begin
      Regex.Match (Declaration, Text (First .. Last), Matches, Index);

      if Regex.Match (Declaration, Text (First .. Last), Index) then
         String'Write
           (Stream (Current_Output),
            (Indent * HT) &
            Matched (Matches (1)) &
            ": " &
            Matched (Matches (2)) &
            ";" &
            LF);
         Index := Matches (0).Last + 1;
         return True;
      else
         return False;
      end if;
   end Parse_Declaration;

   function Parse_Close return Boolean is
      Matches : Regex.Match_Array (0 .. 1);
   begin
      Regex.Match (Selector_Close, Text (First .. Last), Matches, Index);

      if Regex.Match (Selector_Close, Text (First .. Last), Index) then
         Indent := Indent - 1;
         String'Write
           (Stream (Current_Output),
            (Indent * HT) & Matched (Matches (1)) & LF);
         Index := Matches (0).Last + 1;
         return True;
      else
         return False;
      end if;
   end Parse_Close;

begin

   Text_IO.Open (Subject_File, Text_IO.In_File, Argument (1));
   Text_IO.Set_Input (Subject_File);
   Read_File;
   Text_IO.Set_Input (Text_IO.Standard_Input);
   Text_IO.Reset (Subject_File, Text_IO.Out_File);
   Text_IO.Set_Output (Subject_File);
   if Parse_Open then
      null;
   else
      raise Malformed_CSS;
   end if;

   loop
      if Parse_Declaration then
         null;
      elsif Parse_Open then
         null;
      elsif Parse_Close then
         null;
      else
         Index := Index + 1;
      end if;

      exit when Index > Last;

   end loop;

exception
   when File_Too_Big =>
      Text_IO.Put_Line
        (Text_IO.Current_Error,
         "File: " & Argument (1) & "  is too big!");

end Css_Formatter;
