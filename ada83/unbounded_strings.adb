package body Unbounded_Strings is

   function "<" (Left, Right: Unbounded_String) return Boolean is
   begin
      return  Left.all < Right.all;
   end "<";
   
   function "<=" (Left, Right: Unbounded_String) return Boolean is
   begin
      return  Left.all <= Right.all;
   end "<=";
   
   function ">" (Left, Right: Unbounded_String) return Boolean is
   begin
      return  Left.all > Right.all;
   end ">";
   
   function ">=" (Left, Right: Unbounded_String) return Boolean is
   begin
      return  Left.all >= Right.all;
   end ">=";
   
   function Equal (Left, Right: Unbounded_String) return Boolean is
   begin
      return  Left.all = Right.all;
   end Equal;


 ------------------------------------------------------------------------------
 -- Concatenation operators
 ------------------------------------------------------------------------------
   function "&" (Left, Right: Unbounded_String) return Unbounded_String is
   begin
      return (new String'(Left.all & Right.all));
   end "&";

   function "&" (Left: Unbounded_String; Right: Character)
                return Unbounded_String is
   begin
      return (new String'(Left.all & Right));
   end "&";
   
   function "&" (Left: Character; Right: Unbounded_String)
                return Unbounded_String is
   begin
      return (new String'(Left & Right.all));
   end "&";
   
   function "&" (Left : Unbounded_String; Right: String) return Unbounded_String is
   begin
      return (new String'(Left.all & Right));
   end "&";
   
   function "&" (Left : String; Right: Unbounded_String) return Unbounded_String is
   begin
      return (new String'(Left & Right.all));
   end "&";


 ------------------------------------------------------------------------------
   function Length (Source: Unbounded_String) return Natural is
   begin
      return Source.all'Length;
   end Length;

 ------------------------------------------------------------------------------
   procedure Assign (Target: in out Unbounded_String;
                   Source: in     Unbounded_String) is
      -- This procedure must work when Source and Target designate the same string
      Result : Unbounded_String;
   begin
      Result := new String'(Source.all);  -- Copy the source string
--      Free (Target);                      -- Free memory held by Target
      Target := Result;                   -- Set Target to point to the copy
   end Assign;
   
   ------------------------------------------------------------------------------
   function Slice (Source : Unbounded_String;
                   Low    : Positive;
                   High   : Natural) return Unbounded_String is
   begin
      if High < Low then                -- Null string?
         return (new String'(""));
      elsif High <= Source.all'Length then  -- Normal case?
         return (new String'(Source.all(Low..High)));
      else                              -- Range out of bounds.
         raise Constraint_Error;
      end if;
   end Slice;

------------------------------------------------------------------------------
   function Element (Source : in Unbounded_String;
                     Index  : in Positive) return Character is
   begin
      return Source.all(Index);
   end Element;
   
   function To_Unbounded_String (Source : in String) return Unbounded_String is
   begin
      return new String'(Source);
   end To_Unbounded_String;
    
   function To_String (Source : in Unbounded_String) return String is
   begin
      return Source.all;   -- return the slice
   end To_String;
------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   procedure Put (File: in Text_IO.File_Type := Text_IO.Current_Output;
                  Item: in Unbounded_String) is
   begin
      Text_IO.Put (File => File, Item => Item.all);
   end Put;

end;
