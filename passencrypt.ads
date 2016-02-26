with Ada.Strings,
     Ada.Strings.UTF_Encoding,
     Ada.Strings.UTF_Encoding.Wide_Strings,
     Ada.Command_Line,
     Ada.Directories,
     Ada.Sequential_IO,
     Interfaces.C_Streams,
     Password_Encode;
use Ada.Strings.UTF_Encoding;
package PassEncrypt is
   package IO is new Ada.Sequential_IO(Password_Encode.Byte);
   use IO;
   type IO_Attachment is (Standard_IO, File_IO, Null_IO);

   procedure Main;

end PassEncrypt;

