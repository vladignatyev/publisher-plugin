/* Automatically generated class - DO NOT MODIFY */

package ru.magicink.publisher.ns
{
	import com.adobe.xmp.core.*;
	import flash.utils.getQualifiedClassName;
	
	[Bindable]
	public class PublisherNamespace
	{
		
		
		
		private var nsp:Namespace;
		private var xmp:XMPMeta;
	
	
		/**
		 * Class representing the publisherNamespace namespace and its properties
		 */
		function PublisherNamespace(context:XMPMeta)
		{
			this.xmp = context;
			nsp = new Namespace( "publisherNamespace", "http://ns.magicink.ru/publisher/" );
			if (xmp.getNamespace(nsp.prefix) != nsp.uri) 
			{
				nsp = xmp.registerNamespace( nsp.uri, nsp.prefix, true );	
			}
			
			
			
			validateNamespace();
		}
		
		private function validateNamespace():void{
			var constructSuccess:Boolean = true;
			
			
			if (assetsMetadata != null){
				constructSuccess &&= PublisherNamespace.isValidAssetsMetadata(assetsMetadata);
			}
			
			if (exportPath != null){
				constructSuccess &&= PublisherNamespace.isValidExportPath(exportPath);
			}
			
			
			
			constructSuccess ||= this.isEnc;
			if (!constructSuccess) PublisherNamespaceXMPContextStatus._status = PublisherNamespaceXMPContextStatus.INVALID;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		* Value of the assetsMetadata property of the publisherNamespace namespace
		* <p>Attempting to set an invalid value will set PublisherNamespaceXMPContextStatus.status to INVALID</p>
		*/
		public function get assetsMetadata():String
		{
			var result:String = xmp.nsp::AssetsMetadata;
			if (result=="null")return null;
			return result;
		}
		
		internal function assetsMetadataIsNull():Boolean{
			var result:String = xmp.nsp::AssetsMetadata;
			return (result == "null");
		}
		
		/**
		 * Checks whether something is a valid value for the assetsMetadata property
		 * @param input Value to validate 
		 */
		public static function isValidAssetsMetadata( input:String ):Boolean 
		{
			return (true);
		}	 
		
		/**
		* Value of the assetsMetadata property of the publisherNamespace namespace
		* <p>Attempting to set an invalid value will set PublisherNamespaceXMPContextStatus.status to INVALID</p>
		*/
		public function set assetsMetadata( input:String ):void
		{
			if (PublisherNamespace.isValidAssetsMetadata(input))
			{
				xmp.nsp::AssetsMetadata = input;
			}
			else
			{
				
				PublisherNamespaceXMPContextStatus._status = PublisherNamespaceXMPContextStatus.INVALID;
			}
		}
		
		internal function deleteAssetsMetadata():void{
			xmp.nsp::AssetsMetadata = null;
		}
		
		/**
		* Value of the exportPath property of the publisherNamespace namespace
		* <p>Attempting to set an invalid value will set PublisherNamespaceXMPContextStatus.status to INVALID</p>
		*/
		public function get exportPath():String
		{
			var result:String = xmp.nsp::ExportPath;
			if (result=="null")return null;
			return result;
		}
		
		internal function exportPathIsNull():Boolean{
			var result:String = xmp.nsp::ExportPath;
			return (result == "null");
		}
		
		/**
		 * Checks whether something is a valid value for the exportPath property
		 * @param input Value to validate 
		 */
		public static function isValidExportPath( input:String ):Boolean 
		{
			return (true);
		}	 
		
		/**
		* Value of the exportPath property of the publisherNamespace namespace
		* <p>Attempting to set an invalid value will set PublisherNamespaceXMPContextStatus.status to INVALID</p>
		*/
		public function set exportPath( input:String ):void
		{
			if (PublisherNamespace.isValidExportPath(input))
			{
				xmp.nsp::ExportPath = input;
			}
			else
			{
				
				PublisherNamespaceXMPContextStatus._status = PublisherNamespaceXMPContextStatus.INVALID;
			}
		}
		
		internal function deleteExportPath():void{
			xmp.nsp::ExportPath = null;
		}
		
		
		
	
			
	
		
		
		
		
		
	
		internal function get initVector():String
		{
			return xmp.nsp::InitVector;
		}    
		
		internal function set initVector( input:String ):void
		{
			xmp.nsp::InitVector = input;
		}
		
		internal function get encPacket():String
		{
			return xmp.nsp::EncPacket;
		}    
		
		internal function set encPacket( input:String ):void
		{
			xmp.nsp::EncPacket = input;
		}
		
		internal function get isEnc():Boolean
		{
			var result:String =xmp.nsp::IsEncrypted; 
			return (result.toLowerCase()=="true");
		}    
		
		internal function set isEnc( input:Boolean ):void
		{
			xmp.nsp::IsEncrypted = input.toString();
		}
		
		internal function deleteIsEnc():void
		{
			xmp.nsp::IsEncrypted = null;
		}
	
	}
}
