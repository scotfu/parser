newtype Parser a = Parser (String -> [(a,String)])
item :: Parser Char
item = Parser (\cs -> case cs of
                   "" -> []
                   (c:cs) -> [(c,cs)])