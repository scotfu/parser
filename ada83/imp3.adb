with Text_IO; use Text_IO;
with SEQUENTIAL_IO;

procedure imp3 is
   package Parse_IO is new Sequential_IO(Character);--return type is character
   Input_file :Parse_IO.File_Type;
   Char: Character;
begin
   Parse_IO.open( File => Input_file,
           Mode => Parse_IO.in_File,
         Name => "test.cfg");
   while not Parse_IO.End_Of_File(Input_File) loop
      Parse_IO.Read(Input_File,Char);
      Put(Char);
   end loop;
   Parse_IO.Close(Input_File);
exception   
   when NAME_ERROR => PUT("ERR:F");

end imp3;






