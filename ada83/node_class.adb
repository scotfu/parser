with TEXT_IO; use TEXT_IO;
package body Node_Class is
   type Node;
   type Node_Ptr is access Node; 

   type Node is 
      record
         Node_Type:Integer;
         Node_Value:String(1..500000);
         Lineno:Integer;
         C1:Node_Ptr;
         C2:Node_Ptr;
         C3:Node_Ptr;
         C4:Node_Ptr;
         C5:Node_Ptr;
         C6:Node_Ptr;
      end record;
   procedure Get_Node is
   begin
      Put("1");
   end Get_Node;
end Node_Class;         
