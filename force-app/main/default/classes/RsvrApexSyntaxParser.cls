/*
 * Copyright 2022 Reservoir Consulting - Toshiki Iga
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Reservoir Apex Language Parser.
 * 
 * This class provide Syntax Parser for Apex Language.
 * 
 * @since 2022-11-23
 */
public class RsvrApexSyntaxParser {
    private static final Boolean IS_DEBUG = true;

    public abstract class SyntaxToken {
        final private List<RsvrApexLexicalParser.LexicalToken> tokenList = new List<RsvrApexLexicalParser.LexicalToken>();
        final private List<RsvrApexLexicalParser.LexicalToken> whitespaceList = new List<RsvrApexLexicalParser.LexicalToken>();

        public List<RsvrApexLexicalParser.LexicalToken> getTokenList() {
            return tokenList;
        }

        public List<RsvrApexLexicalParser.LexicalToken> getWhitespaceList() {
            return whitespaceList;
        }
    }

    /**
     * 一旦不明トークンにおまとめ。
     */
    public class UnknownToken extends SyntaxToken {
    }

    /** NO OPERATION TOKEN */
    public class NopToken extends SyntaxToken {
    }

    public List<SyntaxToken> unify(List<RsvrApexLexicalParser.LexicalToken> lexicalTokenList) {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#unity: begin');
        final List<SyntaxToken> result = new List<SyntaxToken>();

        List<RsvrApexLexicalParser.LexicalToken> bufList = new List<RsvrApexLexicalParser.LexicalToken>();

        for (RsvrApexLexicalParser.LexicalToken look : lexicalTokenList) {
            if (look instanceof RsvrApexLexicalParser.WhitespaceToken
             || look instanceof RsvrApexLexicalParser.CommentToken) {
                bufList.add(look);
            } else {
                UnknownToken unkToken = new UnknownToken();
                unkToken.getTokenList().add(look);
                if (bufList.size() > 0) {
                    unkToken.getWhitespaceList().addAll(bufList);
                    bufList.clear();
                }
                result.add(unkToken);
            }
        }

        // 10個のダミーを最後に付与。
        RsvrApexLexicalParser.WhitespaceToken dummy = new RsvrApexLexicalParser.WhitespaceToken();
        dummy.type = 'Whitespace';
        dummy.target = '';
        dummy.original = '';
        for (Integer i = 0; i < 10; i++) {
            NopToken nop = new NopToken();
            nop.getTokenList().add(dummy);
            result.add(nop);
        }

        return result;
    }

    RsvrApexSyntaxParserInput input;

    public SyntaxToken parse(List<SyntaxToken> tokenList) {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parse: begin');
        input = new RsvrApexSyntaxParserInput(tokenList);

        // TODO TRIGGER TBDE

        CompilationUnitToken compToken = new CompilationUnitToken();

        TypeDeclarationToken typeDecToken = parseTypeDeclaration();
        if (typeDecToken != null) {
            compToken.typeDeclaration = typeDecToken;
        }

        return compToken;
    }

    //////////////////////////////
    // 仕切り直し

    /////////////////////////////////////////////////////////////////
    // // entry point for Apex trigger files
    // triggerUnit
    //     : TRIGGER id ON id LPAREN triggerCase (COMMA triggerCase)* RPAREN block EOF
    //     ;
    // 
    // triggerCase
    //     : (BEFORE|AFTER) (INSERT|UPDATE|DELETE|UNDELETE)
    //     ;

    /////////////////////////////////////////////////////////////////
    // // entry point for Apex class files
    // compilationUnit
    //     : typeDeclaration EOF
    //     ;
        
    public class CompilationUnitToken extends SyntaxToken {
        public TypeDeclarationToken typeDeclaration {get; set;}

        public String dump(String indent) {
            String strDump = '\n' + (indent + 'CompilationUnitToken:\n');

            if (typeDeclaration != null) {
                strDump += typeDeclaration.dump(indent + '  ');
            }

            return strDump;
        }
    }

    /////////////////////////////////////////////////////////////////
    // typeDeclaration
    //     : modifier* classDeclaration
    //     | modifier* enumDeclaration
    //     | modifier* interfaceDeclaration
    //     ;

    public class TypeDeclarationToken extends SyntaxToken {
        public final List<ModifierToken> modifierList = new List<ModifierToken>();

        public ClassDeclarationToken classDeclaration {get; set;}
        public EnumDeclarationToken enumDeclaration {get; set;}
        public InterfaceDeclarationToken interfaceDeclaration {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'TypeDeclaration:\n');

            for (ModifierToken modTok : modifierList) {
                strDump += modTok.dump(indent + '  ');
            }
            if (classDeclaration != null) {
                strDump += classDeclaration.dump(indent + '  ');
            }
            if (enumDeclaration != null) {
                strDump += enumDeclaration.dump(indent + '  ');
            }
            if (interfaceDeclaration != null) {
                strDump += interfaceDeclaration.dump(indent + '  ');
            }

            return strDump;
        }
    }

    private TypeDeclarationToken parseTypeDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseTypeDeclaration: begin');
        input.mark();
        TypeDeclarationToken typeDecToken = new TypeDeclarationToken();
        for (;;) {
            ModifierToken modifyToken = parseModifier();
            if (modifyToken == null) {
                input.reset();
                break;
            }
            input.mark();
            typeDecToken.modifierList.add(modifyToken);
        }

        ClassDeclarationToken classTok = parseClassDeclaration();
        if (classTok != null) {
            input.mark();
            typeDecToken.classDeclaration = classTok;
            return typeDecToken;
        } else {
            input.reset();
        }

        EnumDeclarationToken enumTok = parseEnumDeclaration();
        if (enumTok != null) {
            input.mark();
            typeDecToken.enumDeclaration = enumTok;
            return typeDecToken;
        } else {
            input.reset();
        }

        InterfaceDeclarationToken interfaceTok = parseInterfaceDeclaration();
        if (interfaceTok != null) {
            input.mark();
            typeDecToken.interfaceDeclaration = interfaceTok;
            return typeDecToken;
        } else {
            input.reset();
        }

        System.debug('PANIC: parseTypeDeclaration: Do not enter here.');
        return null;
    }

    /////////////////////////////////////////////////////////////////
    // classDeclaration
    //     : CLASS id
    //       (EXTENDS typeRef)?
    //       (IMPLEMENTS typeList)?
    //       classBody
    //     ;

    public class ClassDeclarationToken extends SyntaxToken {
        public String identifier {get; set;}
        public TypeRefToken extend {get; set;}
        public TypeListToken implement {get; set;}
        public ClassBodyToken classBody {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'ClassDeclaration:\n');
            strDump += (indent + '  identifier: ' + identifier + '\n');
            if (extend != null) {
                strDump += (indent + '  extends: ' + extend.dump(indent + '  ') + '\n');
            }
            if (implement != null) {
                strDump += (indent + '  implements: ' + implement.dump(indent + '  ') + '\n');
            }
            if (classBody != null) {
                strDump += (indent + '  classBody: ' + classBody.dump(indent + '  ') + '\n');
            }
            return strDump;
        }
    }

    private ClassDeclarationToken parseClassDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseClassDeclaration: begin');

        input.mark();
        // CLASS
        RsvrApexLexicalParser.KeywordToken keyTok = input.getFirstKeywordToken();
        if (keyTok == null) {
            input.reset();
            return null;
        }

        // id
        RsvrApexLexicalParser.IdentifierToken idTok = input.getFirstIdentifierToken();
        if (idTok == null) {
            input.reset();
            return null;
        }

        // これで確定扱いとします。
        input.mark();
        ClassDeclarationToken clsDecTok = new ClassDeclarationToken();
        clsDecTok.identifier = idTok.target;

        for (;;) {
            RsvrApexLexicalParser.KeywordToken nextKeyTok = input.getFirstKeywordToken();
            if (nextKeyTok == null) {
                input.reset();
                break;
            } else {
                if (nextKeyTok.no == RsvrApexConstants.KEY_EXTENDS) {
                    // EXTENDS
                    // TODO
                    System.debug('PANIC: ERROR NOT IMPLEMENTED. RsvrApexConstants.KEY_EXTENDS');
                }
                if (nextKeyTok.no != RsvrApexConstants.KEY_IMPLEMENTS) {
                    // IMPLEMENTS
                    // TODO
                    System.debug('PANIC: ERROR NOT IMPLEMENTED. RsvrApexConstants.KEY_IMPLEMENTS');
                }
            }
        }

        input.mark();
        ClassBodyToken cbody = parseClassBody();
        if (cbody == null) {
            System.debug('PANIC: parseClassDeclaration: Do not enter here.');
            input.reset();
        } else {
            clsDecTok.classBody = cbody;
        }

        return clsDecTok;
    }
    
    /////////////////////////////////////////////////////////////////
    // enumDeclaration
    //     : ENUM id
    //       LBRACE enumConstants? RBRACE
    //     ;

    public class EnumDeclarationToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'EnumDeclaration:\n');
            return strDump;
        }
    }

    private EnumDeclarationToken parseEnumDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseEnumDeclaration: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseEnumDeclaration');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // enumConstants
    //  	: id (COMMA id)*
    //    	;

    /////////////////////////////////////////////////////////////////
    // interfaceDeclaration
    //     : INTERFACE id (EXTENDS typeList)? interfaceBody
    //     ;

    public class InterfaceDeclarationToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'InterfaceDeclaration:\n');
            return strDump;
        }
    }

    private InterfaceDeclarationToken parseInterfaceDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseInterfaceDeclaration: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseInterfaceDeclaration');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // typeList
    //     : typeRef (COMMA typeRef)*
    //     ;

    public class TypeListToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'TypeListToken:\n');
            return strDump;
        }
    }

    private TypeListToken parseTypeList() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseTypeList: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseTypeList');

        return null;
    }
    
    /////////////////////////////////////////////////////////////////
    // classBody
    //     : LBRACE classBodyDeclaration* RBRACE
    //     ;

    public class ClassBodyToken extends SyntaxToken {
        public List<ClassBodyDeclarationToken> classBodyDeclarationList = new List<ClassBodyDeclarationToken>();

        public String dump(String indent) {
            String strDump = (indent + 'ClassBody:\n');
            for (ClassBodyDeclarationToken look : classBodyDeclarationList) {
                strDump += look.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private ClassBodyToken parseClassBody() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseClassBody: begin');
        input.mark();
        ClassBodyToken bodyTok = new ClassBodyToken();

        RsvrApexLexicalParser.SeparatorToken lbrace1 = input.getFirstSeparatorToken();
        if (lbrace1 == null || lbrace1.no != RsvrApexConstants.SEP_LBRACE) {
            input.reset();
            return null;
        }
        
        for (;;) {
            ClassBodyDeclarationToken bodyDecTok = parseClassBodyDeclaration();
            if (bodyDecTok == null) {
                input.reset();
                break;
            }
            bodyTok.classBodyDeclarationList.add(bodyDecTok);
        }
        
        RsvrApexLexicalParser.SeparatorToken rbrace1 = input.getFirstSeparatorToken();
        if (rbrace1 == null || rbrace1.no != RsvrApexConstants.SEP_RBRACE) {
            System.debug('PANIC: parseClassBody: #2: Do not enter here.');
            input.reset();
            return null;
        }

        return bodyTok;
    }
    
    /////////////////////////////////////////////////////////////////
    // interfaceBody
    //     : LBRACE interfaceMethodDeclaration* RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // classBodyDeclaration
    //     : SEMI
    //     | STATIC? block
    //     | modifier* memberDeclaration
    //     ;

    public class ClassBodyDeclarationToken extends SyntaxToken {
        public BlockToken block {get; set;}
        public List<ModifierToken> modifierList = new List<ModifierToken>();
        public MemberDeclarationToken memberDeclaration {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'ClassBodyDeclaration:\n');
            if (block != null) {
                strDump += block.dump(indent + '  ');
            }
            for (ModifierToken tok : modifierList) {
                strDump += tok.dump(indent + '  ');
            }
            if (memberDeclaration != null) {
                strDump += memberDeclaration.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private ClassBodyDeclarationToken parseClassBodyDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseClassBodyDeclaration: begin');
        input.mark();
        ClassBodyDeclarationToken result = new ClassBodyDeclarationToken();

        RsvrApexLexicalParser.SeparatorToken semi1 = input.getFirstSeparatorToken();
        if (semi1 == null || semi1.no != RsvrApexConstants.SEP_SEMI) {
            input.reset();
            // to next.
        } else {
            // hit
            input.mark();
            result.getTokenList().add(semi1);
            return result;
        }

        RsvrApexLexicalParser.KeywordToken key1 = input.getFirstKeywordToken();
        if (key1 == null || key1.no != RsvrApexConstants.KEY_STATIC) {
            input.reset();
            // to next.
        } else {
            // hit
            input.mark();
            result.getTokenList().add(key1);

            BlockToken block = parseBlock();
            if (block == null) {
                input.reset();
                System.debug('PANIC: parseClassBodyDeclaration: #1: Do not enter here.');
            } else {
                input.mark();
                result.block = block;
            }
            return result;
        }

        for (;;) {
            ModifierToken modifyToken = parseModifier();
            if (modifyToken == null) {
                input.reset();
                break;
            }
            input.mark();
            result.modifierList.add(modifyToken);
        }

        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseClassBodyDeclaration: on parseMemberDeclaration: begin.');
        MemberDeclarationToken memberDec = parseMemberDeclaration();
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseClassBodyDeclaration: on parseMemberDeclaration: end: ' + memberDec);
        if (memberDec == null) {
            input.reset();
            return null;
        } else {
            input.mark();
            result.memberDeclaration = memberDec;
        }

        return result;
    }

    /////////////////////////////////////////////////////////////////
    // /* Unify all annotation & modifiers so we can give better error messages */
    // modifier
    //     : annotation
    //     | GLOBAL
    //     | PUBLIC
    //     | PROTECTED
    //     | PRIVATE
    //     | TRANSIENT
    //     | STATIC
    //     | ABSTRACT
    //     | FINAL
    //     | WEBSERVICE
    //     | OVERRIDE
    //     | VIRTUAL
    //     | TESTMETHOD
    //     | WITH SHARING
    //     | WITHOUT SHARING
    //     | INHERITED SHARING
    //     ;

    /**
     * AnnotationToken は作らずに、ModifierToken を使用。
     */
    public class ModifierToken extends SyntaxToken {
        // 非Annotation用のフィールド。
        public Integer no {get; set;}

        // Annotation用のフィールド。
        public String qualifiedName {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'Modifier:\n');
            strDump += indent + '  no: ' + no + '\n';
            strDump += indent + '  qualifiedName: ' + qualifiedName + '\n';
            return strDump;
        }
    }

    private ModifierToken parseModifier() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseModifier: begin');
        ModifierToken annoToken = parseAnnotation();
        if (annoToken != null) {
            return annoToken;
        }

        input.mark();
        RsvrApexLexicalParser.KeywordToken keyTok = input.getFirstKeywordToken();
        if (keyTok == null) {
            input.reset();
            return null;
        }

        if (keyTok.no == RsvrApexConstants.KEY_GLOBAL
        || keyTok.no == RsvrApexConstants.KEY_PUBLIC
        || keyTok.no == RsvrApexConstants.KEY_PROTECTED
        || keyTok.no == RsvrApexConstants.KEY_PRIVATE
        || keyTok.no == RsvrApexConstants.KEY_TRANSIENT
        || keyTok.no == RsvrApexConstants.KEY_STATIC
        || keyTok.no == RsvrApexConstants.KEY_ABSTRACT
        || keyTok.no == RsvrApexConstants.KEY_FINAL
        || keyTok.no == RsvrApexConstants.KEY_WEBSERVICE
        || keyTok.no == RsvrApexConstants.KEY_OVERRIDE
        || keyTok.no == RsvrApexConstants.KEY_VIRTUAL
        || keyTok.no == RsvrApexConstants.KEY_TESTMETHOD) {
            input.mark();
            ModifierToken modTok = new ModifierToken();
            modTok.no = keyTok.no;
            modTok.qualifiedName = keyTok.target;
            modTok.getTokenList().add(keyTok);
            return modTok;
        }

        if (keyTok.no == RsvrApexConstants.KEY_WITH
        || keyTok.no == RsvrApexConstants.KEY_WITHOUT
        || keyTok.no == RsvrApexConstants.KEY_INHERITED) {
            RsvrApexLexicalParser.KeywordToken keyTok2 = input.getFirstKeywordToken();
            if (keyTok2 == null) {
                input.reset();
                return null;
            }

            input.mark();
            ModifierToken modTok = new ModifierToken();
            modTok.no = keyTok.no;
            modTok.qualifiedName = keyTok.target + ' ' + keyTok2.target;
            modTok.getTokenList().add(keyTok);
            modTok.getTokenList().add(keyTok2);
            return modTok;
        }
    
        input.reset();
        return null;
    }

    /**
     * annotation
    : ATSIGN qualifiedName ( LPAREN ( elementValuePairs | elementValue )? RPAREN )?
    ;
     */
    private ModifierToken parseAnnotation() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseAnnotation: begin');
        input.mark();
        RsvrApexLexicalParser.LexicalToken tok1 = input.readToken().getTokenList().get(0);
        if ((tok1 instanceof RsvrApexLexicalParser.AtsignToken) == false) {
            input.reset();
            return null;
        }

        String qualifiedName = parseQualifiedName();
        if (qualifiedName == null) {
            input.reset();
            return null;
        }

        // ここまででAnnotation は確定。
        input.mark();
        ModifierToken modToken = new ModifierToken();
        modToken.qualifiedName = qualifiedName;

        // TODO この先が未実装。
        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseAnnotation');

        return modToken;
    }

    /////////////////////////////////////////////////////////////////
    // memberDeclaration
    //     : methodDeclaration
    //     | fieldDeclaration
    //     | constructorDeclaration
    //     | interfaceDeclaration
    //     | classDeclaration
    //     | enumDeclaration
    //     | propertyDeclaration
    //     ;
    // 
    // /* We use rule this even for void methods which cannot have [] after parameters.
    //    This simplifies grammar and we can consider void to be a type, which
    //    renders the [] matching as a context-sensitive issue or a semantic check
    //    for invalid return type after parsing.
    //  */

    public class MemberDeclarationToken extends SyntaxToken {
        public MethodDeclarationToken methodDeclaration {get; set;}
        public FieldDeclarationToken fieldDeclaration {get; set;}
        public ConstructorDeclarationToken constructorDeclaration {get; set;}
        public InterfaceDeclarationToken interfaceDeclaration {get; set;}
        public ClassDeclarationToken classDeclaration {get; set;}
        public EnumDeclarationToken enumDeclaration {get; set;}
        public PropertyDeclarationToken propertyDeclaration {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'MemberDeclaration:\n');
            if (methodDeclaration != null) {
                strDump += methodDeclaration.dump(indent + '  ');
            }
            if (fieldDeclaration != null) {
                strDump += fieldDeclaration.dump(indent + '  ');
            }
            if (constructorDeclaration != null) {
                strDump += constructorDeclaration.dump(indent + '  ');
            }
            if (interfaceDeclaration != null) {
                strDump += interfaceDeclaration.dump(indent + '  ');
            }
            if (classDeclaration != null) {
                strDump += classDeclaration.dump(indent + '  ');
            }
            if (enumDeclaration != null) {
                strDump += enumDeclaration.dump(indent + '  ');
            }
            if (propertyDeclaration != null) {
                strDump += propertyDeclaration.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private MemberDeclarationToken parseMemberDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseMemberDeclaration: begin');
        input.mark();
        MemberDeclarationToken result = new MemberDeclarationToken();

        //     : methodDeclaration

        MethodDeclarationToken methodDec = parseMethodDeclaration();
        if (methodDec == null) {
            input.reset();
        } else {
            input.mark();
            result.methodDeclaration = methodDec;
            return result;
        }

        //     | fieldDeclaration

        FieldDeclarationToken fieldDec = parseFieldDeclaration();
        if (fieldDec == null) {
            input.reset();
        } else {
            input.mark();
            result.fieldDeclaration = fieldDec;
            return result;
        }

        //     | constructorDeclaration

        ConstructorDeclarationToken constDec = parseConstructorDeclaration();
        if (constDec == null) {
            input.reset();
        } else {
            input.mark();
            result.constructorDeclaration = constDec;
            return result;
        }

        //     | interfaceDeclaration

        InterfaceDeclarationToken interDec = parseInterfaceDeclaration();
        if (interDec == null) {
            input.reset();
        } else {
            input.mark();
            result.interfaceDeclaration = interDec;
            return result;
        }

        //     | classDeclaration

        ClassDeclarationToken classDec = parseClassDeclaration();
        if (classDec == null) {
            input.reset();
        } else {
            input.mark();
            result.classDeclaration = classDec;
            return result;
        }

        //     | enumDeclaration

        EnumDeclarationToken enumDec = parseEnumDeclaration();
        if (enumDec == null) {
            input.reset();
        } else {
            input.mark();
            result.enumDeclaration = enumDec;
            return result;
        }

        //     | propertyDeclaration

        PropertyDeclarationToken propTok = parsePropertyDeclaration();
        if (propTok == null) {
            input.reset();
        } else {
            input.mark();
            result.propertyDeclaration = propTok;
            return result;
        }

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // methodDeclaration
    //     : (typeRef|VOID) id formalParameters
    //       (   block
    //       |   SEMI
    //       )
    //     ;

    public class MethodDeclarationToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'MethodDeclaration:\n');
            return strDump;
        }
    }

    private MethodDeclarationToken parseMethodDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseMethodDeclaration: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseMethodDeclaration');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // constructorDeclaration
    //     : qualifiedName formalParameters block
    //     ;

    public class ConstructorDeclarationToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'ConstructorDeclaration:\n');
            return strDump;
        }
    }

    private ConstructorDeclarationToken parseConstructorDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseConstructorDeclaration: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseConstructorDeclaration');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // fieldDeclaration
    //     : typeRef variableDeclarators SEMI
    //     ;

    public class FieldDeclarationToken extends SyntaxToken {
        TypeRefToken typeRef {get; set;}
        VariableDeclaratorsToken variableDeclarators {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'FieldDeclaration:\n');
            if (typeRef != null) {
                strDump += typeRef.dump(indent + '  ');
            }
            if (variableDeclarators != null) {
                strDump += variableDeclarators.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private FieldDeclarationToken parseFieldDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseFieldDeclaration: begin');

        input.mark();
        FieldDeclarationToken fieldDeclarationToken = new FieldDeclarationToken();

        TypeRefToken typeTok = parseTypeRef();
        if (typeTok == null) {
            input.reset();
            return null;
        }
        fieldDeclarationToken.typeRef = typeTok;

        VariableDeclaratorsToken decs = parseVariableDeclarators();
        if (decs == null) {
            System.debug('PANIC: parseFieldDeclaration: #1: Do not enter here.');
            input.reset();
            return null;
        }
        fieldDeclarationToken.variableDeclarators = decs;

        RsvrApexLexicalParser.SeparatorToken semi1 = input.getFirstSeparatorToken();
        if (semi1 == null || semi1.no != RsvrApexConstants.SEP_SEMI) {
            System.debug('PANIC: parseFieldDeclaration: #2: Do not enter here.: Missing SEMI (end of line).');
            input.reset();
            return null;
        }

        input.mark();
        return fieldDeclarationToken;
    }

    /////////////////////////////////////////////////////////////////
    // propertyDeclaration
    //     : typeRef id LBRACE propertyBlock* RBRACE
    //     ;

    public class PropertyDeclarationToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'PropertyDeclaration:\n');
            return strDump;
        }
    }

    private PropertyDeclarationToken parsePropertyDeclaration() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parsePropertyDeclaration: begin');
        input.mark();

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parsePropertyDeclaration');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // interfaceMethodDeclaration
    //     : modifier* (typeRef|VOID) id formalParameters SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // variableDeclarators
    //     : variableDeclarator (COMMA variableDeclarator)*
    //     ;

    public class VariableDeclaratorsToken extends SyntaxToken {
        List<VariableDeclaratorToken> variableDeclaratorList = new List<VariableDeclaratorToken>();

        public String dump(String indent) {
            String strDump = (indent + 'VariableDeclarators:\n');
            for (VariableDeclaratorToken tok : variableDeclaratorList) {
                strDump += tok.dump(indent + '  ');

            }
            return strDump;
        }
    }

    private VariableDeclaratorsToken parseVariableDeclarators() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseVariableDeclarators: begin');
        input.mark();
        VariableDeclaratorsToken decls = new VariableDeclaratorsToken();
        VariableDeclaratorToken tok1 = parseVariableDeclarator();
        if (tok1 == null) {
            input.reset();
            return null;
        }

        input.mark();
        decls.variableDeclaratorList.add(tok1);

        for (;;) {
            RsvrApexLexicalParser.SeparatorToken dot1 = input.getFirstSeparatorToken();
            if (dot1 == null || dot1.no != RsvrApexConstants.SEP_COMMA) {
                input.reset();
                break;
            }
            
            VariableDeclaratorToken tok2 = parseVariableDeclarator();
            if (tok2 == null) {
                System.debug('PANIC: parseVariableDeclarators: #1: Do not enter here.');
                input.reset();
                break;
            }
            input.mark();
            decls.variableDeclaratorList.add(tok2);
        }

        return decls;
    }

    /////////////////////////////////////////////////////////////////
    // variableDeclarator
    //     : id (ASSIGN expression)?
    //     ;

    public class VariableDeclaratorToken extends SyntaxToken {
        public String identifier {get; set;}
        public ExpressionToken expression {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'VariableDeclarator:\n');
            strDump += (indent + '  ' + 'identifier: ' + identifier + '\n');
            if (expression != null) {
                strDump += (indent + '  ' + 'ASSIGN\n');
                strDump += expression.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private VariableDeclaratorToken parseVariableDeclarator() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseVariableDeclarator: begin');
        input.mark();
        RsvrApexLexicalParser.IdentifierToken iden1 = input.getFirstIdentifierToken();
        if (iden1 == null) {
            input.reset();
            return null;
        }

        input.mark();
        VariableDeclaratorToken result = new VariableDeclaratorToken();
        result.identifier = iden1.target;

        RsvrApexLexicalParser.OperatorToken eq1 = input.getFirstOperatorToken();
        if (eq1 == null || eq1.no != RsvrApexConstants.OPE_ASSIGN) {
            input.reset();
        } else {
            ExpressionToken exp = parseExpression();
            if (exp == null) {
                System.debug('PANIC: parseVariableDeclarator: #1: Do not enter here.');
                input.reset();
            } else {
                input.mark();
                result.expression = exp;
            }
        }
        return result;
    }

    /////////////////////////////////////////////////////////////////
    // arrayInitializer
    //     : LBRACE (expression (COMMA expression)* (COMMA)? )? RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // typeRef
    //     : typeName (DOT typeName)* arraySubscripts
    //     ;

    public class TypeRefToken extends SyntaxToken {
        public List<TypeNameToken> typeNameList = new List<TypeNameToken>();
        public ArraySubscriptsToken arraySubscripts {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'TypeRef:\n');
            return strDump;
        }
    }

    private TypeRefToken parseTypeRef() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseTypeRef: begin');
        input.mark();
        TypeRefToken typeR = new TypeRefToken();

        TypeNameToken typeName1 = parseTypeName();
        if (typeName1 == null) {
            input.reset();
            return null;
        }
        input.mark();
        typeR.typeNameList.add(typeName1);

        for (;;) {
            RsvrApexLexicalParser.SeparatorToken dot1 = input.getFirstSeparatorToken();
            if (dot1 == null || dot1.no != RsvrApexConstants.SEP_COMMA) {
                input.reset();
                break;
            }

            TypeNameToken typeName2 = parseTypeName();
            if (typeName2 == null) {
                System.debug('PANIC: parseTypeRef: #1: Do not enter here.');
                input.reset();
                break;
            }
            input.mark();
            typeR.typeNameList.add(typeName2);
        }

        ArraySubscriptsToken arraySub = parseArraySubscripts();
        if (arraySub == null) {
            input.reset();
        } else {
            typeR.arraySubscripts = arraySub;
        }

        return typeR;
    }

    /////////////////////////////////////////////////////////////////
    // arraySubscripts
    //     : (LBRACK RBRACK)*
    //     ;

    public class ArraySubscriptsToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'ArraySubscripts:\n');
            return strDump;
        }
    }

    private ArraySubscriptsToken parseArraySubscripts() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseArraySubscripts: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseArraySubscripts');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // typeName
    //     : LIST typeArguments?
    //     | SET typeArguments?
    //     | MAP typeArguments?
    //     | id typeArguments?
    //     ;

    public class TypeNameToken  extends SyntaxToken {
        String collectionName {get; set;}
        String identifier {get; set;}
        TypeArgumentsToken typeArguments {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'TypeName:\n');
            if (collectionName != null) {
                strDump += indent + collectionName + '\n';
            }
            if (identifier != null) {
                strDump += indent + identifier + '\n';
            }
            if (typeArguments != null) {
                strDump += indent + typeArguments.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private TypeNameToken parseTypeName() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseTypeName: begin');
        input.mark();
        TypeNameToken result = new TypeNameToken();

        RsvrApexLexicalParser.KeywordToken key1 = input.getFirstKeywordToken();
        if (key1 == null) {
            input.reset();
        } else {
            if (key1.no == RsvrApexConstants.KEY_LIST) {
                input.mark();
                result.collectionName = 'LIST';
                TypeArgumentsToken arg = parseTypeArguments();
                if (arg == null) {
                    input.reset();
                } else {
                    input.mark();
                    result.typeArguments = arg;
                }
                return result;
            }
            if (key1.no == RsvrApexConstants.KEY_SET) {
                input.mark();
                result.collectionName = 'SET';
                TypeArgumentsToken arg = parseTypeArguments();
                if (arg == null) {
                    input.reset();
                } else {
                    input.mark();
                    result.typeArguments = arg;
                }
                return result;
            }
            if (key1.no == RsvrApexConstants.KEY_MAP) {
                input.mark();
                result.collectionName = 'MAP';
                TypeArgumentsToken arg = parseTypeArguments();
                if (arg == null) {
                    input.reset();
                } else {
                    input.mark();
                    result.typeArguments = arg;
                }
                return result;
            }
        }

        RsvrApexLexicalParser.IdentifierToken iden1 = input.getFirstIdentifierToken();
        if (iden1 != null) {
            input.mark();
            result.identifier = iden1.target;
            return result;
        }

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // typeArguments
    //     : LT typeList GT
    //     ;

    public class TypeArgumentsToken  extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'TypeArguments:\n');
            return strDump;
        }
    }

    private TypeArgumentsToken parseTypeArguments() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseTypeArguments: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseTypeArguments');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // formalParameters
    //     : LPAREN formalParameterList? RPAREN
    //     ;

    public class FormalParametersToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'FormalParameters:\n');
            return strDump;
        }
    }

    private FormalParametersToken parseFormalParameters() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseFormalParameters: begin');

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseFormalParameters');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // formalParameterList
    //     : formalParameter (COMMA formalParameter)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // formalParameter
    //     : modifier* typeRef id
    //     ;

    /////////////////////////////////////////////////////////////////
    // qualifiedName
    //     : id (DOT id)*
    //     ;

    // QualifiedNameToken は作らない。???

    private String parseQualifiedName() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseQualifiedName: begin');
        String qualifiedName = '';
        RsvrApexLexicalParser.LexicalToken tok1 = input.readToken().getTokenList().get(0);
        if ((tok1 instanceof RsvrApexLexicalParser.IdentifierToken) == false) {
            input.reset();
            return null;
        }
        input.mark();
        qualifiedName += tok1.target;

        for (;;) {
            RsvrApexLexicalParser.LexicalToken tok2 = input.readToken().getTokenList().get(0);
            if (tok2.target != '.') {
                input.reset();
                break;
            }

            RsvrApexLexicalParser.LexicalToken tok3 = input.readToken().getTokenList().get(0);
            if ((tok3 instanceof RsvrApexLexicalParser.IdentifierToken) == false) {
                input.reset();
                break;
            }

            qualifiedName += tok2.target;
            qualifiedName += tok3.target;
        }

        return qualifiedName;
    }
    
    /////////////////////////////////////////////////////////////////
    // literal
    //     : IntegerLiteral
    //     | LongLiteral
    //     | NumberLiteral
    //     | StringLiteral
    //     | BooleanLiteral
    //     | NULL
    //     ;

    public class LiteralToken extends SyntaxToken {
        public RsvrApexLexicalParser.LiteralToken literal {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'Literal:\n');
            if (literal != null) {
                strDump += (indent + '  tok: ' + literal.target + ' (' + literal.type + ')\n');
            }
            return strDump;
        }
    }

    private LiteralToken parseLiteral() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseLiteral: begin');
        input.mark();
        LiteralToken result = new LiteralToken();

        RsvrApexLexicalParser.LiteralToken lit1 = input.getFirstLiteralToken();
        if (lit1 != null) {
            input.mark();
            result.literal = lit1;
            return result;
        }

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // // ANNOTATIONS

    /////////////////////////////////////////////////////////////////
    // annotation
    //     : ATSIGN qualifiedName ( LPAREN ( elementValuePairs | elementValue )? RPAREN )?
    //     ;

    /////////////////////////////////////////////////////////////////
    // elementValuePairs
    //     : elementValuePair (COMMA? elementValuePair)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // elementValuePair
    //     : id ASSIGN elementValue
    //     ;

    /////////////////////////////////////////////////////////////////
    // elementValue
    //     : expression
    //     | annotation
    //     | elementValueArrayInitializer
    //     ;

    /////////////////////////////////////////////////////////////////
    // elementValueArrayInitializer
    //     : LBRACE (elementValue (COMMA elementValue)*)? (COMMA)? RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // // STATEMENTS / BLOCKS

    /////////////////////////////////////////////////////////////////
    // block
    //     : LBRACE statement* RBRACE
    //     ;

    public class BlockToken extends SyntaxToken {
        public List<StatementToken> statements = new List<StatementToken>();

        public String dump(String indent) {
            String strDump = (indent + 'BlockToken:\n');

            for (StatementToken stmt : statements) {
                strDump += (stmt.dump(indent + '  '));
            }

            return strDump;
        }
    }

    private BlockToken parseBlock() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseBlock: begin');
        input.mark();
        BlockToken block = new BlockToken();

        RsvrApexLexicalParser.SeparatorToken lbrace1 = input.getFirstSeparatorToken();
        if (lbrace1 == null || lbrace1.no != RsvrApexConstants.SEP_LBRACE) {
            input.reset();
            return null;
        }

        // 確定とする。
        input.mark();
        for (;;) {
            StatementToken statementTok = parseStatement();
            if (statementTok == null) {
                input.reset();
                break;
            }
            block.statements.add(statementTok);
        }
        
        RsvrApexLexicalParser.SeparatorToken rbrace1 = input.getFirstSeparatorToken();
        if (rbrace1 == null || rbrace1.no != RsvrApexConstants.SEP_RBRACE) {
            System.debug('PANIC: parseBlock: #1: Do not enter here.');
            input.reset();
            return null;
        }

        return block;
    }

    /////////////////////////////////////////////////////////////////
    // localVariableDeclarationStatement
    //     : localVariableDeclaration SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // localVariableDeclaration
    //     : modifier* typeRef variableDeclarators
    //     ;

    /////////////////////////////////////////////////////////////////
    // statement
    //     : block
    //     | ifStatement
    //     | switchStatement
    //     | forStatement
    //     | whileStatement
    //     | doWhileStatement
    //     | tryStatement
    //     | returnStatement
    //     | throwStatement
    //     | breakStatement
    //     | continueStatement
    //     | insertStatement
    //     | updateStatement
    //     | deleteStatement
    //     | undeleteStatement
    //     | upsertStatement
    //     | mergeStatement
    //     | runAsStatement
    //     | localVariableDeclarationStatement
    //     | expressionStatement
    //     ;

    public class StatementToken extends SyntaxToken {

        public String dump(String indent) {
            String strDump = (indent + 'StatementToken:\n');
            return strDump;
        }
    }

    private StatementToken parseStatement() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseStatement: begin');
        input.mark();

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseStatement');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // ifStatement
    //     : IF parExpression statement (ELSE statement)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // switchStatement
    //     : SWITCH ON expression LBRACE whenControl+ RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // whenControl
    //     : WHEN whenValue block
    //     ;

    /////////////////////////////////////////////////////////////////
    // whenValue
    //     : ELSE
    //     | whenLiteral (COMMA whenLiteral)*
    //     | id id
    //     ;

    /////////////////////////////////////////////////////////////////
    // whenLiteral
    //     : (SUB)? IntegerLiteral
    //     | LongLiteral
    //     | StringLiteral
    //     | NULL
    //     | id
    //     // Salesforce tolerates paren pairs around each literal,
    //     // although this is not explicitly documented.
    //     | LPAREN whenLiteral RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // forStatement
    //     : FOR LPAREN forControl RPAREN (statement | SEMI)
    //     ;

    /////////////////////////////////////////////////////////////////
    // whileStatement
    //     : WHILE parExpression (statement | SEMI)
    //     ;

    /////////////////////////////////////////////////////////////////
    // doWhileStatement
    //     : DO statement WHILE parExpression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // tryStatement
    //     : TRY block (catchClause+ finallyBlock? | finallyBlock)
    //     ;

    /////////////////////////////////////////////////////////////////
    // returnStatement
    //     : RETURN expression? SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // throwStatement
    //     : THROW expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // breakStatement
    //     : BREAK SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // continueStatement
    //     : CONTINUE SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // insertStatement
    //     : INSERT expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // updateStatement
    //     : UPDATE expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // deleteStatement
    //     : DELETE expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // undeleteStatement
    //     : UNDELETE expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // upsertStatement
    //     : UPSERT expression qualifiedName? SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // mergeStatement
    //     : MERGE expression expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // runAsStatement
    //     : SYSTEMRUNAS LPAREN expressionList? RPAREN block
    //     ;

    /////////////////////////////////////////////////////////////////
    // expressionStatement
    //     : expression SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // propertyBlock
    //     : modifier* (getter | setter)
    //     ;

    /////////////////////////////////////////////////////////////////
    // getter
    //     : GET (SEMI | block)
    //     ;

    /////////////////////////////////////////////////////////////////
    // setter
    //     : SET (SEMI | block)
    //     ;

    /////////////////////////////////////////////////////////////////
    // catchClause
    //     : CATCH LPAREN modifier* qualifiedName id RPAREN block
    //     ;

    /////////////////////////////////////////////////////////////////
    // finallyBlock
    //     : FINALLY block
    //     ;

    /////////////////////////////////////////////////////////////////
    // forControl
    //     : enhancedForControl
    //     | forInit? SEMI expression? SEMI forUpdate?
    //     ;

    /////////////////////////////////////////////////////////////////
    // forInit
    //     : localVariableDeclaration
    //     | expressionList
    //     ;

    /////////////////////////////////////////////////////////////////
    // enhancedForControl
    //     : typeRef id COLON expression
    //     ;

    /////////////////////////////////////////////////////////////////
    // forUpdate
    //     : expressionList
    //     ;

    /////////////////////////////////////////////////////////////////
    // // EXPRESSIONS

    /////////////////////////////////////////////////////////////////
    // parExpression
    //     : LPAREN expression RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // expressionList
    //     : expression (COMMA expression)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // expression
    //     : primary                                                                                         # primaryExpression
    //     | expression (DOT | QUESTIONDOT)
    //         ( dotMethodCall
    //         | anyId
    //         )                                                                                             # dotExpression
    //     | expression LBRACK expression RBRACK                                                             # arrayExpression
    //     | methodCall                                                                                      # methodCallExpression
    //     | NEW creator                                                                                     # newExpression
    //     | LPAREN typeRef RPAREN expression                                                                # castExpression
    //     | LPAREN expression RPAREN                                                                        # subExpression
    //     | expression (INC | DEC)                                                                          # postOpExpression
    //     | (ADD|SUB|INC|DEC) expression                                                                    # preOpExpression
    //     | (TILDE|BANG) expression                                                                         # negExpression
    //     | expression (MUL|DIV) expression                                                             # arth1Expression
    //     | expression (ADD|SUB) expression                                                                 # arth2Expression
    //     | expression (LT LT | GT GT GT | GT GT) expression                                                # bitExpression
    //     | expression (GT | LT) ASSIGN? expression                                                         # cmpExpression
    //     | expression INSTANCEOF typeRef                                                                   # instanceOfExpression
    //     | expression (TRIPLEEQUAL | TRIPLENOTEQUAL | EQUAL | NOTEQUAL | LESSANDGREATER ) expression       # equalityExpression
    //     | expression BITAND expression                                                                    # bitAndExpression
    //     | expression CARET expression                                                                     # bitNotExpression
    //     | expression BITOR expression                                                                     # bitOrExpression
    //     | expression AND expression                                                                       # logAndExpression
    //     | expression OR expression                                                                        # logOrExpression
    //     | <assoc=right> expression QUESTION expression COLON expression                                   # condExpression
    //     | <assoc=right> expression
    //       (   ASSIGN
    //       |   ADD_ASSIGN
    //       |   SUB_ASSIGN
    //       |   MUL_ASSIGN
    //       |   DIV_ASSIGN
    //       |   AND_ASSIGN
    //       |   OR_ASSIGN
    //       |   XOR_ASSIGN
    //       |   RSHIFT_ASSIGN
    //       |   URSHIFT_ASSIGN
    //       |   LSHIFT_ASSIGN
    //       )
    //       expression                                                                                     # assignExpression
    //     ;

    public class ExpressionToken extends SyntaxToken {
        public PrimaryToken primary {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'Expression:\n');
            if (primary != null) {
                strDump += primary.dump(indent + '  ');
            }
            return strDump;
        }
    }

    private ExpressionToken parseExpression() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parseExpression: begin');

        //     : primary                                                                                         # primaryExpression
        //     | expression (DOT | QUESTIONDOT)
        //         ( dotMethodCall
        //         | anyId
        //         )                                                                                             # dotExpression
        //     | expression LBRACK expression RBRACK                                                             # arrayExpression
        //     | methodCall                                                                                      # methodCallExpression
        //     | NEW creator                                                                                     # newExpression
        //     | LPAREN typeRef RPAREN expression                                                                # castExpression
        //     | LPAREN expression RPAREN                                                                        # subExpression
        //     | expression (INC | DEC)                                                                          # postOpExpression
        //     | (ADD|SUB|INC|DEC) expression                                                                    # preOpExpression
        //     | (TILDE|BANG) expression                                                                         # negExpression
        //     | expression (MUL|DIV) expression                                                             # arth1Expression
        //     | expression (ADD|SUB) expression                                                                 # arth2Expression
        //     | expression (LT LT | GT GT GT | GT GT) expression                                                # bitExpression
        //     | expression (GT | LT) ASSIGN? expression                                                         # cmpExpression
        //     | expression INSTANCEOF typeRef                                                                   # instanceOfExpression
        //     | expression (TRIPLEEQUAL | TRIPLENOTEQUAL | EQUAL | NOTEQUAL | LESSANDGREATER ) expression       # equalityExpression
        //     | expression BITAND expression                                                                    # bitAndExpression
        //     | expression CARET expression                                                                     # bitNotExpression
        //     | expression BITOR expression                                                                     # bitOrExpression
        //     | expression AND expression                                                                       # logAndExpression
        //     | expression OR expression                                                                        # logOrExpression
        //     | <assoc=right> expression QUESTION expression COLON expression                                   # condExpression
        //     | <assoc=right> expression
        //       (   ASSIGN
        //       |   ADD_ASSIGN
        //       |   SUB_ASSIGN
        //       |   MUL_ASSIGN
        //       |   DIV_ASSIGN
        //       |   AND_ASSIGN
        //       |   OR_ASSIGN
        //       |   XOR_ASSIGN
        //       |   RSHIFT_ASSIGN
        //       |   URSHIFT_ASSIGN
        //       |   LSHIFT_ASSIGN
        //       )
        //       expression                                                                                     # assignExpression
        //     ;

        input.mark();
        ExpressionToken result = new ExpressionToken();

        PrimaryToken pri1 = parsePrimary();
        if (pri1 != null) {
            input.mark();
            result.primary = pri1;
            return result;
        }

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parseExpression');

        return null;
    }


    /////////////////////////////////////////////////////////////////
    // primary
    //     : THIS                                                                                           # thisPrimary
    //     | SUPER                                                                                          # superPrimary
    //     | literal                                                                                        # literalPrimary
    //     | typeRef DOT CLASS                                                                              # typeRefPrimary
    //     | id                                                                                             # idPrimary
    //     | soqlLiteral                                                                                    # soqlPrimary
    //     | soslLiteral                                                                                    # soslPrimary
    //     ;

    public class PrimaryToken extends SyntaxToken {
        //     : THIS                                                                                           # thisPrimary
        //     | SUPER                                                                                          # superPrimary
        public LiteralToken literal {get; set;}
        //     | typeRef DOT CLASS                                                                              # typeRefPrimary
        //     | id                                                                                             # idPrimary
        public String identifier {get; set;}

        public String dump(String indent) {
            String strDump = (indent + 'Primary:\n');
            if (literal != null) {
                strDump += literal.dump(indent + '  ');
            }
            if (identifier != null) {
                strDump += indent + ': ' + identifier;
            }
            return strDump;
        }
    }

    private PrimaryToken parsePrimary() {
        if (IS_DEBUG) System.debug('TRACE: RsvrApexSyntaxParser#parsePrimary: begin');
        input.mark();
        PrimaryToken result = new PrimaryToken();
        //     : THIS                                                                                           # thisPrimary
        //     | SUPER                                                                                          # superPrimary
        //     | literal                                                                                        # literalPrimary
        LiteralToken lit1 = parseLiteral();
        if (lit1 != null) {
            input.mark();
            result.literal = lit1;
            return result;
        }

        //     | typeRef DOT CLASS                                                                              # typeRefPrimary
        //     | id                                                                                             # idPrimary
        //     | soqlLiteral                                                                                    # soqlPrimary
        //     | soslLiteral                                                                                    # soslPrimary

        System.debug('PANIC: ERROR NOT IMPLEMENTED. parsePrimary');

        return null;
    }

    /////////////////////////////////////////////////////////////////
    // methodCall
    //     : id LPAREN expressionList? RPAREN
    //     | THIS LPAREN expressionList? RPAREN
    //     | SUPER LPAREN expressionList? RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // dotMethodCall
    //     : anyId LPAREN expressionList? RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // creator
    //     :  createdName (noRest | classCreatorRest | arrayCreatorRest | mapCreatorRest | setCreatorRest)
    //     ;

    /////////////////////////////////////////////////////////////////
    // createdName
    //     : idCreatedNamePair (DOT idCreatedNamePair)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // idCreatedNamePair
    //     : anyId (LT typeList GT)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // noRest
    //     : LBRACE RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // classCreatorRest
    //     : arguments
    //     ;

    /////////////////////////////////////////////////////////////////
    // arrayCreatorRest
    //     : LBRACK expression RBRACK
    //     | LBRACK RBRACK arrayInitializer?
    //     ;

    /////////////////////////////////////////////////////////////////
    // mapCreatorRest
    //     : LBRACE mapCreatorRestPair (COMMA mapCreatorRestPair )* RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // mapCreatorRestPair
    //     : expression MAPTO expression
    //     ;

    /////////////////////////////////////////////////////////////////
    // setCreatorRest
    // 	: LBRACE expression (COMMA ( expression ))* RBRACE
    // 	;

    /////////////////////////////////////////////////////////////////
    // arguments
    //     : LPAREN expressionList? RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // // SOQL

    /////////////////////////////////////////////////////////////////
    // soqlLiteral
    //     : LBRACK query RBRACK
    //     ;

    /////////////////////////////////////////////////////////////////
    // query
    //     : SELECT selectList
    //         FROM fromNameList
    //         usingScope?
    //         whereClause?
    //         withClause?
    //         groupByClause?
    //         orderByClause?
    //         limitClause?
    //         offsetClause?
    //         allRowsClause?
    //         forClauses
    //         (UPDATE updateList)?
    //         ;

    /////////////////////////////////////////////////////////////////
    // subQuery
    //     : SELECT subFieldList
    //         FROM fromNameList
    //         whereClause?
    //         orderByClause?
    //         limitClause?
    //         forClauses
    //         (UPDATE updateList)?
    //         ;

    /////////////////////////////////////////////////////////////////
    // selectList
    //     : selectEntry (COMMA selectEntry)*;

    /////////////////////////////////////////////////////////////////
    // selectEntry
    //     : fieldName soqlId?
    //     | soqlFunction soqlId?
    //     | LPAREN subQuery RPAREN soqlId?
    //     | typeOf
    //     ;

    /////////////////////////////////////////////////////////////////
    // fieldName
    //     : soqlId (DOT soqlId)*;

    /////////////////////////////////////////////////////////////////
    // fromNameList
    //     : fieldName soqlId? (COMMA fieldName soqlId?)*;

    /////////////////////////////////////////////////////////////////
    // subFieldList
    //     : subFieldEntry (COMMA subFieldEntry)*;

    /////////////////////////////////////////////////////////////////
    // subFieldEntry
    //     : fieldName soqlId?
    //     | soqlFunction soqlId?;

    /////////////////////////////////////////////////////////////////
    // soqlFieldsParameter
    //     : ALL
    //     | CUSTOM
    //     | STANDARD;

    /////////////////////////////////////////////////////////////////
    // soqlFunction
    //     : AVG LPAREN fieldName RPAREN
    //     | COUNT LPAREN RPAREN
    //     | COUNT LPAREN fieldName RPAREN
    //     | COUNT_DISTINCT LPAREN fieldName RPAREN
    //     | MIN LPAREN fieldName RPAREN
    //     | MAX LPAREN fieldName RPAREN
    //     | SUM LPAREN fieldName RPAREN
    //     | TOLABEL LPAREN fieldName RPAREN
    //     | FORMAT LPAREN fieldName RPAREN
    //     | CALENDAR_MONTH LPAREN dateFieldName RPAREN
    //     | CALENDAR_QUARTER LPAREN dateFieldName RPAREN
    //     | CALENDAR_YEAR LPAREN dateFieldName RPAREN
    //     | DAY_IN_MONTH LPAREN dateFieldName RPAREN
    //     | DAY_IN_WEEK LPAREN dateFieldName RPAREN
    //     | DAY_IN_YEAR LPAREN dateFieldName RPAREN
    //     | DAY_ONLY LPAREN dateFieldName RPAREN
    //     | FISCAL_MONTH LPAREN dateFieldName RPAREN
    //     | FISCAL_QUARTER LPAREN dateFieldName RPAREN
    //     | FISCAL_YEAR LPAREN dateFieldName RPAREN
    //     | HOUR_IN_DAY LPAREN dateFieldName RPAREN
    //     | WEEK_IN_MONTH LPAREN dateFieldName RPAREN
    //     | WEEK_IN_YEAR LPAREN dateFieldName RPAREN
    //     | FIELDS LPAREN soqlFieldsParameter RPAREN
    //     | DISTANCE LPAREN locationValue COMMA locationValue COMMA StringLiteral RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    //  dateFieldName
    //     : CONVERT_TIMEZONE LPAREN fieldName RPAREN
    //     | fieldName
    //     ;

    /////////////////////////////////////////////////////////////////
    // locationValue
    //     : fieldName
    //     | boundExpression
    //     | GEOLOCATION LPAREN coordinateValue COMMA coordinateValue  RPAREN
    //     ;

    /////////////////////////////////////////////////////////////////
    // coordinateValue
    //     : signedNumber
    //     | boundExpression
    //     ;

    /////////////////////////////////////////////////////////////////
    // typeOf
    //     : TYPEOF fieldName whenClause+ elseClause? END;

    /////////////////////////////////////////////////////////////////
    // whenClause
    //     : WHEN fieldName THEN fieldNameList;

    /////////////////////////////////////////////////////////////////
    // elseClause
    //     : ELSE fieldNameList;

    /////////////////////////////////////////////////////////////////
    // fieldNameList
    //     : fieldName (COMMA fieldName)*;

    /////////////////////////////////////////////////////////////////
    // usingScope
    //     : USING SCOPE soqlId;

    /////////////////////////////////////////////////////////////////
    // whereClause
    //     : WHERE logicalExpression;

    /////////////////////////////////////////////////////////////////
    // logicalExpression
    //     : conditionalExpression (SOQLAND conditionalExpression)*
    //     | conditionalExpression (SOQLOR conditionalExpression)*
    //     | NOT conditionalExpression;

    /////////////////////////////////////////////////////////////////
    // conditionalExpression
    //     : LPAREN logicalExpression RPAREN
    //     | fieldExpression;

    /////////////////////////////////////////////////////////////////
    // fieldExpression
    //     : fieldName comparisonOperator value
    //     | soqlFunction comparisonOperator value;

    /////////////////////////////////////////////////////////////////
    // comparisonOperator
    //     : ASSIGN | NOTEQUAL | LT | GT | LT ASSIGN | GT ASSIGN | LESSANDGREATER | LIKE | IN | NOT IN | INCLUDES | EXCLUDES;

    /////////////////////////////////////////////////////////////////
    // value
    //     : NULL
    //     | BooleanLiteral
    //     | signedNumber
    //     | StringLiteral
    //     | DateLiteral
    //     | DateTimeLiteral
    //     | dateFormula
    //     | IntegralCurrencyLiteral (DOT IntegerLiteral?)?
    //     | LPAREN subQuery RPAREN
    //     | valueList
    //     | boundExpression
    //     ;

    /////////////////////////////////////////////////////////////////
    // valueList
    //     : LPAREN value (COMMA value)* RPAREN;

    /////////////////////////////////////////////////////////////////
    // // TODO: NumberLiteral has trailing [dD]?, SOQL does not support this but a fix would need wider changes
    // signedNumber
    //     : (ADD | SUB)? (IntegerLiteral | NumberLiteral);

    /////////////////////////////////////////////////////////////////
    // withClause
    //     : WITH DATA CATEGORY filteringExpression
    //     | WITH SECURITY_ENFORCED
    //     | WITH logicalExpression;

    /////////////////////////////////////////////////////////////////
    // filteringExpression
    //     : dataCategorySelection (AND dataCategorySelection)*;

    /////////////////////////////////////////////////////////////////
    // dataCategorySelection
    //     : soqlId filteringSelector dataCategoryName;

    /////////////////////////////////////////////////////////////////
    // dataCategoryName
    //     : soqlId
    //     | LPAREN soqlId (COMMA soqlId)* LPAREN;

    /////////////////////////////////////////////////////////////////
    // filteringSelector
    //     : AT | ABOVE | BELOW | ABOVE_OR_BELOW;

    /////////////////////////////////////////////////////////////////
    // groupByClause
    //     : GROUP BY selectList (HAVING logicalExpression)?
    //     | GROUP BY ROLLUP LPAREN fieldName (COMMA fieldName)* RPAREN
    //     | GROUP BY CUBE LPAREN fieldName (COMMA fieldName)* RPAREN;

    /////////////////////////////////////////////////////////////////
    // orderByClause
    //     : ORDER BY fieldOrderList;

    /////////////////////////////////////////////////////////////////
    // fieldOrderList
    //     : fieldOrder (COMMA fieldOrder)*;

    /////////////////////////////////////////////////////////////////
    // fieldOrder
    //     : fieldName (ASC | DESC)? (NULLS (FIRST|LAST))?
    //     | soqlFunction (ASC | DESC)? (NULLS (FIRST|LAST))?;

    /////////////////////////////////////////////////////////////////
    // limitClause
    //     : LIMIT IntegerLiteral
    //     | LIMIT boundExpression;

    /////////////////////////////////////////////////////////////////
    // offsetClause
    //     : OFFSET IntegerLiteral
    //     | OFFSET boundExpression;

    /////////////////////////////////////////////////////////////////
    // allRowsClause
    //     : ALL ROWS;

    /////////////////////////////////////////////////////////////////
    // forClauses
    //     : (FOR (VIEW | UPDATE | REFERENCE))*;

    /////////////////////////////////////////////////////////////////
    // boundExpression
    //     : COLON expression;

    /////////////////////////////////////////////////////////////////
    // dateFormula
    //     : YESTERDAY
    //     | TODAY
    //     | TOMORROW
    //     | LAST_WEEK
    //     | THIS_WEEK
    //     | NEXT_WEEK
    //     | LAST_MONTH
    //     | THIS_MONTH
    //     | NEXT_MONTH
    //     | LAST_90_DAYS
    //     | NEXT_90_DAYS
    //     | LAST_N_DAYS_N COLON signedInteger
    //     | NEXT_N_DAYS_N COLON signedInteger
    //     | NEXT_N_WEEKS_N COLON signedInteger
    //     | LAST_N_WEEKS_N COLON signedInteger
    //     | NEXT_N_MONTHS_N COLON signedInteger
    //     | LAST_N_MONTHS_N COLON signedInteger
    //     | THIS_QUARTER
    //     | LAST_QUARTER
    //     | NEXT_QUARTER
    //     | NEXT_N_QUARTERS_N COLON signedInteger
    //     | LAST_N_QUARTERS_N COLON signedInteger
    //     | THIS_YEAR
    //     | LAST_YEAR
    //     | NEXT_YEAR
    //     | NEXT_N_YEARS_N COLON signedInteger
    //     | LAST_N_YEARS_N COLON signedInteger
    //     | THIS_FISCAL_QUARTER
    //     | LAST_FISCAL_QUARTER
    //     | NEXT_FISCAL_QUARTER
    //     | NEXT_N_FISCAL_QUARTERS_N COLON signedInteger
    //     | LAST_N_FISCAL_QUARTERS_N COLON signedInteger
    //     | THIS_FISCAL_YEAR
    //     | LAST_FISCAL_YEAR
    //     | NEXT_FISCAL_YEAR
    //     | NEXT_N_FISCAL_YEARS_N COLON signedInteger
    //     | LAST_N_FISCAL_YEARS_N COLON signedInteger
    //     ;

    /////////////////////////////////////////////////////////////////
    // signedInteger
    //     : (ADD | SUB)? IntegerLiteral;

    /////////////////////////////////////////////////////////////////
    // soqlId
    //     : id;

    /////////////////////////////////////////////////////////////////
    // // SOSL
    // soslLiteral
    //     : FindLiteral soslClauses RBRACK
    //     | LBRACK FIND boundExpression soslClauses RBRACK
    //     ;

    /////////////////////////////////////////////////////////////////
    // soslLiteralAlt
    //     : FindLiteralAlt soslClauses RBRACK
    //     ;

    /////////////////////////////////////////////////////////////////
    // soslClauses
    //     : (IN searchGroup)?
    //       (RETURNING fieldSpecList)?
    //       (WITH DIVISION ASSIGN StringLiteral)?
    //       (WITH DATA CATEGORY filteringExpression)?
    //       (WITH SNIPPET (LPAREN TARGET_LENGTH ASSIGN IntegerLiteral RPAREN)? )?
    //       (WITH NETWORK IN LPAREN networkList RPAREN)?
    //       (WITH NETWORK ASSIGN StringLiteral)?
    //       (WITH PRICEBOOKID ASSIGN StringLiteral)?
    //       (WITH METADATA ASSIGN StringLiteral)?
    //       limitClause?
    //       (UPDATE updateList)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // searchGroup
    //     : (ALL|EMAIL|NAME|PHONE|SIDEBAR) FIELDS
    //     ;

    /////////////////////////////////////////////////////////////////
    // fieldSpecList
    //     : fieldSpec (COMMA fieldSpecList)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // fieldSpec
    //     : soslId (LPAREN fieldList
    //         (WHERE logicalExpression)?
    //         (USING LISTVIEW ASSIGN soslId)?
    //         (ORDER BY fieldOrderList)?
    //         limitClause?
    //         offsetClause?
    //         RPAREN)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // fieldList
    //     : soslId (COMMA fieldList)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // updateList
    //     : updateType (COMMA updateList)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // updateType
    //     : TRACKING | VIEWSTAT;

    /////////////////////////////////////////////////////////////////
    // networkList
    //     : StringLiteral (COMMA networkList)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // soslId
    //     : id (DOT soslId)*;

    /////////////////////////////////////////////////////////////////
    // // Identifiers
    // 
    // // Some keywords can be used as general identifiers, this is likely an over simplification of the actual
    // // rules but divining them from playing with Apex is very difficult. We could let any be used but that
    // // can significantly impact the parser performance by creating ambiguities.
    // id
    //     : Identifier
    //     | AFTER
    //     | BEFORE
    //     | GET
    //     | INHERITED
    //     | INSTANCEOF
    //     | SET
    //     | SHARING
    //     | SWITCH
    //     | TRANSIENT
    //     | TRIGGER
    //     | WHEN
    //     | WITH
    //     | WITHOUT
    //     // SOQL Values
    //     | IntegralCurrencyLiteral
    //     // SOQL Specific Keywords
    //     | SELECT
    //     | COUNT
    //     | FROM
    //     | AS
    //     | USING
    //     | SCOPE
    //     | WHERE
    //     | ORDER
    //     | BY
    //     | LIMIT
    //     | SOQLAND
    //     | SOQLOR
    //     | NOT
    //     | AVG
    //     | COUNT_DISTINCT
    //     | MIN
    //     | MAX
    //     | SUM
    //     | TYPEOF
    //     | END
    //     | THEN
    //     | LIKE
    //     | IN
    //     | INCLUDES
    //     | EXCLUDES
    //     | ASC
    //     | DESC
    //     | NULLS
    //     | FIRST
    //     | LAST
    //     | GROUP
    //     | ALL
    //     | ROWS
    //     | VIEW
    //     | HAVING
    //     | ROLLUP
    //     | TOLABEL
    //     | OFFSET
    //     | DATA
    //     | CATEGORY
    //     | AT
    //     | ABOVE
    //     | BELOW
    //     | ABOVE_OR_BELOW
    //     | SECURITY_ENFORCED
    //     | REFERENCE
    //     | CUBE
    //     | FORMAT
    //     | TRACKING
    //     | VIEWSTAT
    //     | STANDARD
    //     | CUSTOM
    //     | DISTANCE
    //     | GEOLOCATION
    //     // SOQL date functions
    //     | CALENDAR_MONTH
    //     | CALENDAR_QUARTER
    //     | CALENDAR_YEAR
    //     | DAY_IN_MONTH
    //     | DAY_IN_WEEK
    //     | DAY_IN_YEAR
    //     | DAY_ONLY
    //     | FISCAL_MONTH
    //     | FISCAL_QUARTER
    //     | FISCAL_YEAR
    //     | HOUR_IN_DAY
    //     | WEEK_IN_MONTH
    //     | WEEK_IN_YEAR
    //     | CONVERT_TIMEZONE
    //     // SOQL date formulas
    //     | YESTERDAY
    //     | TODAY
    //     | TOMORROW
    //     | LAST_WEEK
    //     | THIS_WEEK
    //     | NEXT_WEEK
    //     | LAST_MONTH
    //     | THIS_MONTH
    //     | NEXT_MONTH
    //     | LAST_90_DAYS
    //     | NEXT_90_DAYS
    //     | LAST_N_DAYS_N
    //     | NEXT_N_DAYS_N
    //     | NEXT_N_WEEKS_N
    //     | LAST_N_WEEKS_N
    //     | NEXT_N_MONTHS_N
    //     | LAST_N_MONTHS_N
    //     | THIS_QUARTER
    //     | LAST_QUARTER
    //     | NEXT_QUARTER
    //     | NEXT_N_QUARTERS_N
    //     | LAST_N_QUARTERS_N
    //     | THIS_YEAR
    //     | LAST_YEAR
    //     | NEXT_YEAR
    //     | NEXT_N_YEARS_N
    //     | LAST_N_YEARS_N
    //     | THIS_FISCAL_QUARTER
    //     | LAST_FISCAL_QUARTER
    //     | NEXT_FISCAL_QUARTER
    //     | NEXT_N_FISCAL_QUARTERS_N
    //     | LAST_N_FISCAL_QUARTERS_N
    //     | THIS_FISCAL_YEAR
    //     | LAST_FISCAL_YEAR
    //     | NEXT_FISCAL_YEAR
    //     | NEXT_N_FISCAL_YEARS_N
    //     | LAST_N_FISCAL_YEARS_N
    //     // SOSL Keywords
    //     | FIND
    //     | EMAIL
    //     | NAME
    //     | PHONE
    //     | SIDEBAR
    //     | FIELDS
    //     | METADATA
    //     | PRICEBOOKID
    //     | NETWORK
    //     | SNIPPET
    //     | TARGET_LENGTH
    //     | DIVISION
    //     | RETURNING
    //     | LISTVIEW
    //     ;

    /////////////////////////////////////////////////////////////////
    // // In dot expressions we, can use a wider set of of identifiers, apparently any of them althogh I have excluding VOID
    // // in the interests of reducing ambiguity
    // anyId
    //     : Identifier
    //     // Apex Keywords
    //     | ABSTRACT
    //     | AFTER
    //     | BEFORE
    //     | BREAK
    //     | CATCH
    //     | CLASS
    //     | CONTINUE
    //     | DELETE
    //     | DO
    //     | ELSE
    //     | ENUM
    //     | EXTENDS
    //     | FINAL
    //     | FINALLY
    //     | FOR
    //     | GET
    //     | GLOBAL
    //     | IF
    //     | IMPLEMENTS
    //     | INHERITED
    //     | INSERT
    //     | INSTANCEOF
    //     | INTERFACE
    //     | LIST
    //     | MAP
    //     | MERGE
    //     | NEW
    //     | NULL
    //     | ON
    //     | OVERRIDE
    //     | PRIVATE
    //     | PROTECTED
    //     | PUBLIC
    //     | RETURN
    //     | SET
    //     | SHARING
    //     | STATIC
    //     | SUPER
    //     | SWITCH
    //     | TESTMETHOD
    //     | THIS
    //     | THROW
    //     | TRANSIENT
    //     | TRIGGER
    //     | TRY
    //     | UNDELETE
    //     | UPDATE
    //     | UPSERT
    //     | VIRTUAL
    //     | WEBSERVICE
    //     | WHEN
    //     | WHILE
    //     | WITH
    //     | WITHOUT
    //     // SOQL Values
    //     | IntegralCurrencyLiteral
    //     // SOQL Specific Keywords
    //     | SELECT
    //     | COUNT
    //     | FROM
    //     | AS
    //     | USING
    //     | SCOPE
    //     | WHERE
    //     | ORDER
    //     | BY
    //     | LIMIT
    //     | SOQLAND
    //     | SOQLOR
    //     | NOT
    //     | AVG
    //     | COUNT_DISTINCT
    //     | MIN
    //     | MAX
    //     | SUM
    //     | TYPEOF
    //     | END
    //     | THEN
    //     | LIKE
    //     | IN
    //     | INCLUDES
    //     | EXCLUDES
    //     | ASC
    //     | DESC
    //     | NULLS
    //     | FIRST
    //     | LAST
    //     | GROUP
    //     | ALL
    //     | ROWS
    //     | VIEW
    //     | HAVING
    //     | ROLLUP
    //     | TOLABEL
    //     | OFFSET
    //     | DATA
    //     | CATEGORY
    //     | AT
    //     | ABOVE
    //     | BELOW
    //     | ABOVE_OR_BELOW
    //     | SECURITY_ENFORCED
    //     | REFERENCE
    //     | CUBE
    //     | FORMAT
    //     | TRACKING
    //     | VIEWSTAT
    //     | STANDARD
    //     | CUSTOM
    //     | DISTANCE
    //     | GEOLOCATION
    //     // SOQL date functions
    //     | CALENDAR_MONTH
    //     | CALENDAR_QUARTER
    //     | CALENDAR_YEAR
    //     | DAY_IN_MONTH
    //     | DAY_IN_WEEK
    //     | DAY_IN_YEAR
    //     | DAY_ONLY
    //     | FISCAL_MONTH
    //     | FISCAL_QUARTER
    //     | FISCAL_YEAR
    //     | HOUR_IN_DAY
    //     | WEEK_IN_MONTH
    //     | WEEK_IN_YEAR
    //     | CONVERT_TIMEZONE
    //     // SOQL date formulas
    //     | YESTERDAY
    //     | TODAY
    //     | TOMORROW
    //     | LAST_WEEK
    //     | THIS_WEEK
    //     | NEXT_WEEK
    //     | LAST_MONTH
    //     | THIS_MONTH
    //     | NEXT_MONTH
    //     | LAST_90_DAYS
    //     | NEXT_90_DAYS
    //     | LAST_N_DAYS_N
    //     | NEXT_N_DAYS_N
    //     | NEXT_N_WEEKS_N
    //     | LAST_N_WEEKS_N
    //     | NEXT_N_MONTHS_N
    //     | LAST_N_MONTHS_N
    //     | THIS_QUARTER
    //     | LAST_QUARTER
    //     | NEXT_QUARTER
    //     | NEXT_N_QUARTERS_N
    //     | LAST_N_QUARTERS_N
    //     | THIS_YEAR
    //     | LAST_YEAR
    //     | NEXT_YEAR
    //     | NEXT_N_YEARS_N
    //     | LAST_N_YEARS_N
    //     | THIS_FISCAL_QUARTER
    //     | LAST_FISCAL_QUARTER
    //     | NEXT_FISCAL_QUARTER
    //     | NEXT_N_FISCAL_QUARTERS_N
    //     | LAST_N_FISCAL_QUARTERS_N
    //     | THIS_FISCAL_YEAR
    //     | LAST_FISCAL_YEAR
    //     | NEXT_FISCAL_YEAR
    //     | NEXT_N_FISCAL_YEARS_N
    //     | LAST_N_FISCAL_YEARS_N
    //     // SOSL Keywords
    //     | FIND
    //     | EMAIL
    //     | NAME
    //     | PHONE
    //     | SIDEBAR
    //     | FIELDS
    //     | METADATA
    //     | PRICEBOOKID
    //     | NETWORK
    //     | SNIPPET
    //     | TARGET_LENGTH
    //     | DIVISION
    //     | RETURNING
    //     | LISTVIEW
    //     ;
}