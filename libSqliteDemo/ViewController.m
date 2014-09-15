//
//  ViewController.m
//  libSqliteDemo
//
//  Created by vic on 14-8-7.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
@interface ViewController ()
{
    sqlite3 *dataBase;
    NSString *dataBaseFilePath;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    dataBaseFilePath=[self dataFilePath];
    [super viewDidLoad];
    [self connectToData];
    [self checkAndCreateTable];
    [self queryDataWithStr:@"INSERT OR REPLACE INTO FIELDS (ROW,FIELD_DATA) VALUES (2,'秋天s是用来')"];
    [self insertData];
    [self queryData];
    sqlite3_close(dataBase);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  打开数据库
 */
-(void)connectToData
{
    if (sqlite3_open([dataBaseFilePath UTF8String], &dataBase)!=SQLITE_OK) {
        sqlite3_close(dataBase);
        NSAssert(0, @"file to open database");
    }
}

/**
 *  检查数据库是否存在否则创建数据库
 */
-(void)checkAndCreateTable
{
    NSString *query=@"CREATE TABLE IF NOT EXISTS FIELDS (ROW INTEGER PRIMARY KEY,FIELD_DATA TEXT);";
    char *error;
    if (sqlite3_exec(dataBase, [query UTF8String], NULL, NULL, &error)!=SQLITE_OK) {
        sqlite3_close(dataBase);
        NSAssert(0, @"error creating table",error);
    }
}

/**
 *  执行sql语句
 *
 *  @param queryStr sql语句
 */
-(void)queryDataWithStr:(NSString *)queryStr
{
    char *error;
    if (sqlite3_exec(dataBase, [queryStr UTF8String], NULL, NULL, &error)!=SQLITE_OK) {
        sqlite3_close(dataBase);
        NSAssert(0, @"error exec %@",queryStr);
    }
}

-(void)insertData
{
    char *insert="INSERT OR REPLACE INTO FIELDS (ROW,FIELD_DATA) VALUES (?,?)";
    char *error = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, insert, -1, &stmt, nil)==SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, 3);
        sqlite3_bind_text(stmt, 2, "wowamdw一二三四五“\"我", -1, NULL);
    }
    if (sqlite3_step(stmt)!=SQLITE_DONE) {
        NSLog(@"error insert :%s",error);
    }
    sqlite3_finalize(stmt);
}

/**
 *  查询数据
 */
-(void)queryData
{
    NSString *query=@"SELECT ROW , FIELD_DATA FROM FIELDS ORDER BY ROW";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dataBase, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int row=sqlite3_column_int(statement, 0);
            char *rowData=(char *)sqlite3_column_text(statement, 1);
            NSLog(@"\nrow:%d field_data:%@",row,[NSString stringWithUTF8String:rowData ]);
        }
    }
}

/**
 *  数据库路径
 *
 *  @return 数据库路径字符串
 */
-(NSString *)dataFilePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDiectory=[paths objectAtIndex:0];
    return [documentDiectory stringByAppendingString:@"data.sqlite"];
}
@end
