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
    }

    private TypeDeclarationToken parseTypeDeclaration() {
        TypeDeclarationToken typeDecToken = new TypeDeclarationToken();
        for (;;) {
            ModifierToken modifyToken = parseModifier();
            if (modifyToken == null) {
                break;
            }
            typeDecToken.modifierList.add(modifyToken);
        }

        ClassDeclarationToken classTok = parseClassDeclaration();
        if (classTok != null) {
            typeDecToken.classDeclaration = classTok;
        }

        return typeDecToken;
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
    }

    private ClassDeclarationToken parseClassDeclaration() {
        System.debug('parseClassDeclaration()');
        input.dumpNextTokens();


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
                }
                if (nextKeyTok.no != RsvrApexConstants.KEY_IMPLEMENTS) {
                    // IMPLEMENTS
                }
            }
        }

        return clsDecTok;
    }
    
    /////////////////////////////////////////////////////////////////
    // enumDeclaration
    //     : ENUM id
    //       LBRACE enumConstants? RBRACE
    //     ;

    public class EnumDeclarationToken extends SyntaxToken {
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
    }

    /////////////////////////////////////////////////////////////////
    // typeList
    //     : typeRef (COMMA typeRef)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // classBody
    //     : LBRACE classBodyDeclaration* RBRACE
    //     ;

    public class ClassBodyToken extends SyntaxToken {
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
    }

    private ModifierToken parseModifier() {
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
    }

    /////////////////////////////////////////////////////////////////
    // methodDeclaration
    //     : (typeRef|VOID) id formalParameters
    //       (   block
    //       |   SEMI
    //       )
    //     ;

    public class MethodDeclarationToken extends SyntaxToken {
    }

    /////////////////////////////////////////////////////////////////
    // constructorDeclaration
    //     : qualifiedName formalParameters block
    //     ;

    public class ConstructorDeclarationToken extends SyntaxToken {
    }

    /////////////////////////////////////////////////////////////////
    // fieldDeclaration
    //     : typeRef variableDeclarators SEMI
    //     ;

    public class FieldDeclarationToken extends SyntaxToken {
    }

    /////////////////////////////////////////////////////////////////
    // propertyDeclaration
    //     : typeRef id LBRACE propertyBlock* RBRACE
    //     ;

    public class PropertyDeclarationToken extends SyntaxToken {
    }

    /////////////////////////////////////////////////////////////////
    // interfaceMethodDeclaration
    //     : modifier* (typeRef|VOID) id formalParameters SEMI
    //     ;

    /////////////////////////////////////////////////////////////////
    // variableDeclarators
    //     : variableDeclarator (COMMA variableDeclarator)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // variableDeclarator
    //     : id (ASSIGN expression)?
    //     ;

    /////////////////////////////////////////////////////////////////
    // arrayInitializer
    //     : LBRACE (expression (COMMA expression)* (COMMA)? )? RBRACE
    //     ;

    /////////////////////////////////////////////////////////////////
    // typeRef
    //     : typeName (DOT typeName)* arraySubscripts
    //     ;

    private TypeRefToken parseTypeRef() {
        return null;
    }

    public class TypeRefToken extends SyntaxToken {
        public List<TypeNameToken> typeNameList = new List<TypeNameToken>();
//        : typeName (DOT typeName)* arraySubscripts
    }

    /////////////////////////////////////////////////////////////////
    // arraySubscripts
    //     : (LBRACK RBRACK)*
    //     ;

    /////////////////////////////////////////////////////////////////
    // typeName
    //     : LIST typeArguments?
    //     | SET typeArguments?
    //     | MAP typeArguments?
    //     | id typeArguments?
    //     ;

    public class TypeNameToken  extends SyntaxToken {
    }

    private TypeNameToken parseTypeName() {
        return null;

    }

    /////////////////////////////////////////////////////////////////
    // typeArguments
    //     : LT typeList GT
    //     ;

    /////////////////////////////////////////////////////////////////
    // formalParameters
    //     : LPAREN formalParameterList? RPAREN
    //     ;

    public class FormalParametersToken extends SyntaxToken {
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