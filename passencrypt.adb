with Ada.Strings,
     Ada.Strings.UTF_Encoding,
     Ada.Strings.UTF_Encoding.Wide_Strings,
     Ada.Command_Line,
     Ada.Directories,
     Ada.Sequential_IO,
     Interfaces.C_Streams,
     Password_Encode;
use Ada.Strings.UTF_Encoding;
package body PassEncrypt is
   use IO;

   procedure Main is
      use Password_Encode;
      use Ada.Command_Line;
      encryption: Password_Encode.Password;
      cmd_i: Positive:= 1;
      DecodeMode: Boolean:= False;
      In_Attachment : IO_Attachment := Null_IO;
      Out_Attachment : IO_Attachment := Null_IO;

      -- Write to StdErr Message.
      procedure WriteErr(Message: in String) is
         use Ada.Strings.UTF_Encoding.Wide_Strings;
      begin
         Password_Encode.PutError(Message =>
                                    Encode(
                                      Decode(
                                        UTF_8_String(Message))));
      end WriteErr;

      -- for processing '-f'. Provide the filename and this procedure
      -- will take care of the opening, reading all of the contents, then
      -- closing. Contents read in this fashion will read all contents
      function Get_PasswordFile_Data(Filename: in String) return String is
         use Ada.Strings.UTF_Encoding.Wide_Strings;
         File_Size: Natural:= Natural(Ada.Directories.Size(Name => Filename));
         subtype File_Data is String(1 .. File_Size);
         package IO is new Ada.Sequential_IO(File_Data);
         File: IO.File_Type;
         Return_Data: File_Data;
      begin
         IO.Open(File => File,
                 Mode => IO.In_File,
                 Name => Filename);
         IO.Read(File => File,
                 Item => Return_Data);
         IO.Close(File => File);
         return String(Return_Data);
      end Get_PasswordFile_Data;
   begin
      for CL_Iteration in 1 .. Command_Line.Argument_Count
      loop
         case Command_Line.Argument(1) is
            when "-k" =>
               encryption.Set(S => UTF_8_String(Command_Line.Argument(1)));
            when "-c" =>
               WriteErr( "No Password/Key given with ""-k"" option");
               exit;
               PasswordEncode.set(password1,Argument(cmd_i));
               PasswordEncode.set(password2,Argument(cmd_i));
               PasswordEncode.set(password3,Argument(cmd_i));
         end case;
         if Argument(cmd_i) = "-f" then
            cmd_i:= cmd_i + 1;
            if cmd_i > Argument_Count then
               WriteErr( "No Password/Key file given with " & '"' & "-f" & '"' & " option");
               exit;
            end if;
            if not password1.IsSet then
               PasswordEncode.set(password1,GetPasswordFileData(Argument(cmd_i)));
            elsif not password2.is_set then
               PasswordEncode.set(password2,GetPasswordFileData(Argument(cmd_i)));
            elsif not password3.is_set then
               PasswordEncode.set(password3,GetPasswordFileData(Argument(cmd_i)));
            end if;
         end if;
         cmd_i:= cmd_i + 1;
      end loop;
      if not password1.is_set then
         PasswordEncode.set(password1,Character'Image(Ada.Strings.Space));
      end if;
   end Main;
end PassEncrypt;

