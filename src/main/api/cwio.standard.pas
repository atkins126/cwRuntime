{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwIO.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwIO
;

type
  ///  <summary>
  ///    Factory record to create instances of IStream / IUnicodeStream in memory.
  ///  </summary>
  TMemoryStream = record
    class function Create( const BufferGranularity: uint64 = 0 ): IUnicodeStream; static;
  end;

  ///  <summary>
  ///    Factory record to create instances of IStream / IUnicodeStream to disk file.
  ///  </summary>
  TFileStream = record
    class function Create( const Filepath: string; const ReadOnly: boolean ): IUnicodeStream; static;
  end;

  ///  <summary>
  ///    Factory record to create instances of ICyclicBuffer in memory.
  ///  </summary>
  TCyclicBuffer = record
    class function Create( const Size: uint64 = 0 ): ICyclicBuffer; static;
  end;

  ///  <summary>
  ///    Factory record to create instances of IBuffer / IUnicodeBuffer in memory.
  ///  </summary>
  TBuffer = record
    class function Create( const aSize: uint64 = 0; const Align16: boolean = FALSE ): IUnicodeBuffer; static;
  end;


implementation
uses
  cwIO.MemoryStream.Standard
, cwIO.FileStream.Standard
, cwIO.CyclicBuffer.Standard
, cwIO.Buffer.Standard
;

class function TFileStream.Create(const Filepath: string; const ReadOnly: boolean): IUnicodeStream;
begin
  Result := cwIO.FileStream.Standard.TFileStream.Create( Filepath, ReadOnly );
end;

class function TCyclicBuffer.Create(const Size: uint64): ICyclicBuffer;
begin
  Result := cwIO.CyclicBuffer.Standard.TCyclicBuffer.Create( Size );
end;

class function TBuffer.Create(const aSize: uint64; const Align16: boolean = FALSE ): IUnicodeBuffer;
begin
  Result := cwIO.Buffer.Standard.TBuffer.Create( aSize, Align16 );
end;

class function TMemoryStream.Create(const BufferGranularity: uint64): IUnicodeStream;
begin
  Result := cwIO.MemoryStream.Standard.TMemoryStream.Create(BufferGranularity);
end;

end.

