pageextension 50100 ItemListExt extends "Item List"
{
    actions
    {
        addafter(AdjustInventory)
        {
            action(ExportAllItemPictures)
            {
                Caption = 'Export All Item Pictures';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Export;

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.Reset();
                    ExportItemPictures(Item);
                end;
            }
            action(ExportSelectedItemPictures)
            {
                Caption = 'Export Selected Item Pictures';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Export;

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.Reset();
                    CurrPage.SetSelectionFilter(Item);
                    if not Item.IsEmpty then
                        ExportItemPictures(Item);
                end;
            }
        }
    }

    local procedure ExportItemPictures(var Item: Record Item)
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ItemPictureOutStream: OutStream;
        ItemPictureInStream: InStream;
        ZipOutStream: OutStream;
        ZipInStream: InStream;
        DataCompression: Codeunit "Data Compression";
        ZipFileName: Text[50];
        ItemTenantMedia: Record "Tenant Media";
        FileName: Text;
        FileExtension: List of [Text];
    begin
        ZipFileName := 'ItemPictures_' + Format(CurrentDateTime) + '.zip';
        DataCompression.CreateZipArchive();
        if Item.FindSet() then
            repeat
                if Item.Picture.Count > 0 then begin
                    ItemTenantMedia.Get(Item.Picture.Item(1));
                    ItemTenantMedia.CalcFields(Content);
                    ItemTenantMedia.Content.CreateInStream(ItemPictureInStream, TextEncoding::UTF8);
                    FileExtension := ItemTenantMedia."Mime Type".Split('/');
                    FileName := Item."No." + '.' + FileExtension.Get(2);
                    DataCompression.AddEntry(ItemPictureInStream, FileName);
                end;
            until Item.Next() = 0;
        TempBlob.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        TempBlob.CreateInStream(ZipInStream);
        DownloadFromStream(ZipInStream, '', '', '', ZipFileName);
    end;
}
