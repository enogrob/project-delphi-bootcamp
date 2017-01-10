//---------------------------------------------------------------------------
// Copyright (c) 2016 Embarcadero Technologies, Inc. All rights reserved.  
//
// This software is the copyrighted property of Embarcadero Technologies, Inc. 
// ("Embarcadero") and its licensors. You may only use this software if you 
// are an authorized licensee of Delphi, C++Builder or RAD Studio 
// (the "Embarcadero Products").  This software is subject to Embarcadero's 
// standard software license and support agreement that accompanied your 
// purchase of the Embarcadero Products and is considered a Redistributable, 
// as such term is defined thereunder. Your use of this software constitutes 
// your acknowledgement of your agreement to the foregoing software license 
// and support agreement. 
//---------------------------------------------------------------------------
unit main_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.AddressBook.Types, FMX.AddressBook, FMX.StdCtrls, FMX.SearchBox,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit, FMX.TabControl,
  FMX.Platform, System.Actions, FMX.ActnList, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.StdActns, FMX.MediaLibrary.Actions, FMX.Objects, FMX.Surfaces;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItemContact: TTabItem;
    edtFirstName: TEdit;
    edtLastName: TEdit;
    edtWorkMail: TEdit;
    btnOK: TButton;
    btnClear: TButton;
    TabItemContacts: TTabItem;
    ToolBar1: TToolBar;
    btnRemove: TSpeedButton;
    btnRefresh: TSpeedButton;
    TabItemGroup: TTabItem;
    edtGroupName: TEdit;
    btnAddGroup: TButton;
    btnRemoveGroup: TButton;
    AddressBook1: TAddressBook;
    ActionList1: TActionList;
    ActionAddContact: TAction;
    ActionRefresh: TAction;
    ActionRemoveGroup: TAction;
    ActionAddGroup: TAction;
    ActionRemoveContact: TAction;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    Label7: TLabel;
    Label8: TLabel;
    Label1: TLabel;
    ContactList: TListBox;
    ContactInfoHeader: TListBoxGroupHeader;
    FirstName: TListBoxItem;
    LastName: TListBoxItem;
    WorkEmail: TListBoxItem;
    Group: TListBoxItem;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    EnterGroup: TListBoxItem;
    SelectGroup: TListBoxItem;
    ComboBox2: TComboBox;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListViewContacts: TListView;
    Photo: TListBoxItem;
    Button1: TButton;
    Image1: TImage;
    TakePhotoFromLibraryAction1: TTakePhotoFromLibraryAction;
    Button2: TButton;
    TakePhotoFromCameraAction1: TTakePhotoFromCameraAction;
    procedure FormShow(Sender: TObject);
    procedure AddressBook1PermissionRequest(ASender: TObject;
      const AMessage: string; const AAccessGranted: Boolean);
    procedure btnClearClick(Sender: TObject);
    procedure AddressBook1ExternalChange(ASender: TObject);
    procedure ActionAddContactExecute(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure ActionRemoveGroupExecute(Sender: TObject);
    procedure ActionAddGroupExecute(Sender: TObject);
    procedure ActionRemoveContactExecute(Sender: TObject);
    procedure TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
    procedure TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
  private
    { Private declarations }
    FDefaultSource: TAddressBookSource;
    FGroups: TAddressBookGroups;
    FKeyPressed: TModalResult;
    procedure FillGroupComboBox(const AGroups: TAddressBookGroups;
      const AComboBox: TComboBox);
    procedure FillGroupList(Source: TAddressBookSource);
    procedure FillContactList(Source: TAddressBookSource);
    procedure AddListViewItem(Contact: TAddressBookContact);
    function ContactExists(ID: Integer): Boolean;
    procedure DeleteContact(const AKey: TModalResult);
    procedure ClearAddContactForm;
  end;

var
  Form1: TForm1;

implementation

uses
  System.Math, FMX.DialogService;

{$R *.fmx}
{$R *.iPhone47in.fmx IOS}

// Update the contact and group list after external changes
procedure TForm1.AddressBook1ExternalChange(ASender: TObject);
begin
  AddressBook1.RevertCurrentChangesAndUpdate;
  ActionRefresh.Execute;
end;

// --------------------------------------------------------------------
// Request a permission to access Address Book
procedure TForm1.AddressBook1PermissionRequest(ASender: TObject;
  const AMessage: string; const AAccessGranted: Boolean);
begin
  if AAccessGranted then
    ActionRefresh.Execute
  else
    ShowMessage('You have no access to Address Book. Reason: ' + AMessage);
end;

// --------------------------------------------------------------------
// Clear the Add New Contact form.
procedure TForm1.ClearAddContactForm;
begin
  edtFirstName.Text := '';
  edtLastName.Text := '';
  edtWorkMail.Text := '';
  ComboBox1.ItemIndex := -1;
  Image1.Bitmap.SetSize(0, 0);
end;

// --------------------------------------------------------------------
// Clear the Add New Contact form.
procedure TForm1.btnClearClick(Sender: TObject);
begin
  ClearAddContactForm;
end;

// --------------------------------------------------------------------
// Remove the selected contact from Address Book
// The apps executes this procedure only if the user confirmed the contact deletion
procedure TForm1.DeleteContact(const AKey: TModalResult);
var
  ContactIndex, ContactID: Integer;
  Contact: TAddressBookContact;
begin
  if AKey = System.UITypes.mrYes then
  begin
    ContactIndex := ListViewContacts.ItemIndex;
    if ContactIndex > -1 then
    begin
      ContactID := ListViewContacts.Items[ContactIndex].Tag;
      Contact := AddressBook1.ContactByID(ContactID);

      try

        AddressBook1.RemoveContact(Contact);
        try
          ListViewContacts.BeginUpdate;
          // Check if the contact was really deleted
          if not ContactExists(ContactID) then
            ListViewContacts.Items.Delete(ContactIndex)
          else
            ShowMessage('Cannot delete this contact: ' + Contact.DisplayName);
        finally
          ListViewContacts.EndUpdate;
        end;
      finally
        Contact.Free;
      end;
    end;
  end;
end;

// --------------------------------------------------------------------
procedure TForm1.FormShow(Sender: TObject);
begin
  // Display this information box while loading the contacts
  if AddressBook1.Supported then
    TDialogService.ShowMessage('Loading contacts...')
  else
    ShowMessage('This platform does not support the Address Book service');
  AddressBook1.RequestPermission;
  TabControl1.ActiveTab := TabItemContacts;
end;

procedure TForm1.TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap.Assign(Image);
end;

procedure TForm1.TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap.Assign(Image);
end;

// --------------------------------------------------------------------
// Fill the group list
procedure TForm1.FillGroupComboBox(const AGroups: TAddressBookGroups;
  const AComboBox: TComboBox);
var
  I: Integer;
begin
  AComboBox.Clear;
  AComboBox.BeginUpdate;
  try
    for I := 0 to AGroups.Count - 1 do
      AComboBox.Items.Add(FGroups.Items[I].Name);
  finally
    AComboBox.EndUpdate;
  end;
  AComboBox.Visible := AGroups.Count > 0;
end;

procedure TForm1.FillGroupList(Source: TAddressBookSource);
begin
  FGroups := TAddressBookGroups.Create;
  AddressBook1.AllGroups(Source, FGroups);

  FillGroupComboBox(FGroups, ComboBox1);
  FillGroupComboBox(FGroups, ComboBox2);

end;

// --------------------------------------------------------------------
// Add a new item to List box
procedure TForm1.ActionAddContactExecute(Sender: TObject);
var
  Contact: TAddressBookContact;
  eMails: TContactEmails;
  Photo: TBitmapSurface;
begin
  Contact := AddressBook1.CreateContact(FDefaultSource);
  try
    try
      Contact.FirstName := edtFirstName.Text;
      Contact.LastName := edtLastName.Text;
      if not Image1.Bitmap.Size.IsZero then
      begin
        Photo := TBitmapSurface.Create;
        try
          Photo.Assign(Image1.Bitmap);
          Contact.Photo := Photo;
          Image1.Bitmap.SetSize(0, 0);
        finally
          Photo.Free;
        end;
      end;
      // Add the work mail
      eMails := TContactEmails.Create;
      try
        eMails.AddEmail(TContactEmail.TLabelKind.Work, edtWorkMail.Text);
        Contact.eMails := eMails;
      finally
        eMails.Free;
      end;
      // Save a newly created contact to Address Book
      AddressBook1.SaveContact(Contact);

    except
      on E: EAddressBookException do
        ShowMessage('Cannot create the contact.' + E.Message);
    end;

    // Add the contact to the selected group, if any
    try
      if InRange(ComboBox1.ItemIndex, 0, FGroups.Count - 1) then
        AddressBook1.AddContactIntoGroup
          (FGroups.Items[ComboBox1.ItemIndex], Contact);
    except
      on E: EAddressBookException do
        ShowMessage('Cannot add the newly created contact to group.' + E.Message);
    end;

    ListViewContacts.BeginUpdate;
    try
      AddListViewItem(Contact);
    finally
      ListViewContacts.EndUpdate;
    end;
    TabControl1.ActiveTab := TabItemContacts;
  finally
    Contact.Free;
  end;
  // Clear the Add Contact Form
  ClearAddContactForm;
end;

// Add a new group
procedure TForm1.ActionAddGroupExecute(Sender: TObject);
var
  Group: TAddressBookGroup;
begin
  Group := AddressBook1.CreateGroup(FDefaultSource);
  try
    Group.Name := edtGroupName.Text;
    try
      AddressBook1.SaveGroup(Group);
      edtGroupName.Text := '';
      TabControl1.ActiveTab := TabItemContacts;
    except
      on E: EAddressBookException do
        ShowMessage('Cannot add this group.' + E.Message);
    end;
    FillGroupList(FDefaultSource);
  finally
    Group.Free;
  end;
end;

// The Action list methods
procedure TForm1.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  ActionAddContact.Enabled := AddressBook1.Supported and
    ((edtFirstName.Text <> '') or (edtLastName.Text <> ''));
  ActionRefresh.Enabled := AddressBook1.Supported;
  ActionAddGroup.Enabled := AddressBook1.Supported;
  ActionRemoveGroup.Visible := (FGroups <> nil) and (FGroups.Count > 0);
  ActionRemoveContact.Enabled := ListViewContacts.ItemIndex > -1;
end;

procedure TForm1.ActionRefreshExecute(Sender: TObject);
begin
  FDefaultSource := AddressBook1.DefaultSource;
  FillGroupList(FDefaultSource);
  FillContactList(FDefaultSource);
end;

procedure TForm1.ActionRemoveContactExecute(Sender: TObject);
begin
  TDialogService.MessageDialog('Do you want to delete this contact?',
    TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbNo, 0, DeleteContact);
end;

procedure TForm1.ActionRemoveGroupExecute(Sender: TObject);
begin
  if (ComboBox2.ItemIndex > -1) and (ComboBox2.ItemIndex < FGroups.Count) Then
  begin
    AddressBook1.RemoveGroup(FGroups.Items[ComboBox2.ItemIndex]);
    FillGroupList(FDefaultSource);
  end;
end;

// Add a new item to the contact list
procedure TForm1.AddListViewItem(Contact: TAddressBookContact);
var
  ListViewItem: TListViewItem;
begin
  ListViewItem := ListViewContacts.Items.Add;
  try
    ListViewItem.Text := Contact.DisplayName;
    ListViewItem.Tag := Contact.ID;
  finally
    ListViewItem.Free;
  end;
end;

// --------------------------------------------------------------------
// Fill the contact list
procedure TForm1.FillContactList(Source: TAddressBookSource);
var
  I: Integer;
  Contacts: TAddressBookContacts;
begin
  Contacts := TAddressBookContacts.Create;
  try
    AddressBook1.AllContacts(Source, Contacts);
    ListViewContacts.BeginUpdate;
    try
      ListViewContacts.Items.Clear;
      for I := 0 to Contacts.Count - 1 do
        AddListViewItem(Contacts.Items[I]);
    finally
      ListViewContacts.EndUpdate;
    end;
  finally
    Contacts.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Check whether the specified contact exists
function TForm1.ContactExists(ID: Integer): Boolean;
var
  Contact: TAddressBookContact;
begin
  Contact := AddressBook1.ContactByID(ID);
  ContactExists := Contact <> nil;
end;

// ---------------------------------------------------------------------------
end.
