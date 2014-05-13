with Text_IO;
package Unbounded_Strings is
   type Unbounded_String is limited private;         -- Unbounded-length string
 
   Null_Unbounded_String: constant Unbounded_String; -- A string with no characters
 
    ------------------------------------------------------------------------------
    ------------------------------------------------------------------------------
    -- Relational operators
   function "<"   (Left, Right : Unbounded_String) return Boolean;
   function "<="  (Left, Right : Unbounded_String) return Boolean;
   function ">"   (Left, Right : Unbounded_String) return Boolean;
   function ">="  (Left, Right : Unbounded_String) return Boolean;
   function Equal (Left, Right : Unbounded_String) return Boolean;
 
    ------------------------------------------------------------------------------
    -- Concatenation operators
    -- Exceptions:  CONSTRAINT_ERROR  is raised if the combined length of the two
    --              parameters exceeds the value of Max_Length
     -----------------------------------------------------------------------------
   function "&" (Left, Right: Unbounded_String) return Unbounded_String;
   function "&" (Left: Unbounded_String; Right: Character) return Unbounded_String;
   function "&" (Left: Character; Right: Unbounded_String) return Unbounded_String;
   function "&" (Left: Unbounded_String; Right: String) return Unbounded_String;
   function "&" (Left: String; Right: Unbounded_String) return Unbounded_String;
 
    ------------------------------------------------------------------------------
    -- Number of characters in a string
   function Length (Source: Unbounded_String) return Natural;
 
    ------------------------------------------------------------------------------
   procedure Assign (Target: in out Unbounded_String;
                      Source: in     Unbounded_String);
 
    ------------------------------------------------------------------------------
    -- The substring of "Source" from "Low" to "High".
    -- Exceptions:  CONSTRAINT_ERROR is raised if Low <= High or
    -- High is greater than Length (Source)
   function Slice (Source : Unbounded_String;
                    Low    : Positive;
                    High   : Natural) return Unbounded_String;
 
    ------------------------------------------------------------------------------
    -- Return the character in the string at the position given by Index.
    -- Exceptions: CONSTRAINT_ERROR is raised if Index is greater than
    --             Length(Source).
   function Element (Source : in Unbounded_String;
                      Index  : in Positive) return Character;
 
    ------------------------------------------------------------------------------
    -- Search for "Pattern" in "Source". If the pattern is found, "Index"
    -- returns the smallest index I such that the slice of "Source" starting
    -- at I matches the pattern.  Otherwise, 0 is returned.

   function To_Unbounded_String (Source: String) return Unbounded_String; 
   function To_String (Source: Unbounded_String) return String;
   
    --------------
    -- Conversions
 
    -- This function converts an unbounded string to a fixed-length string
--    function To_String (Source: Unbounded_String) return String;
 
    ------------------------------------------------------------------------------
    -- This function converts a fixed-length string to a Unbounded-length string
    -- Exceptions:  CONSTRAINT_ERROR is raised if Source'Last > Max_Length
 --   function To_Unbounded_String (Source: String) return Unbounded_String;
 
   -- procedure Get_Line (File: in  Text_IO.File_Type := Text_IO.Current_Input;
  --                                              Item: out Unbounded_String);
 
    -- Unbounded-length string equivalent to Text_IO.Put
   procedure Put (File: in Text_IO.File_Type := Text_IO.Current_Output;
                                           Item: in Unbounded_String);
 
private
   type Unbounded_String is access String;
 
   Null_Unbounded_String : constant Unbounded_String := new String'("");
 
end Unbounded_Strings;
