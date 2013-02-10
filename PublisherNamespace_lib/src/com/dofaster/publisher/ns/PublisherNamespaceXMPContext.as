/* Automatically generated class - DO NOT MODIFY */

package com.dofaster.publisher.ns
{
	import com.adobe.xmp.core.XMPMeta;
	import flash.utils.describeType;
	import flash.utils.ByteArray;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.Hex;
	import com.hurlant.crypto.hash.SHA256;
	
	
	/**
	 * Class representing the entire XMP context containing the "publisherNamespace" namespace.
	 *
	 * <p>Passing encrypted XMP without a decryption key will set the value of PublisherNamespaceXMPContextStatus.status to MISSING DECRYPTION KEY</p>
	 * <p>WARNING: Passing badly-formed XML to the constructor will cause an ArgumentError to be thrown.</p>
	 */
	public class PublisherNamespaceXMPContext
	{
		private var context:XMPMeta;
		
		private var _publisherNamespace:PublisherNamespace;
		private var xml:XML;
		private var bindings:Object = new Object();
		
		public function PublisherNamespaceXMPContext( xmlIn:String="", decryptionKey:String = null)
		{
			xml = new XML( xmlIn );
			context = new XMPMeta( xml );
			_publisherNamespace = new PublisherNamespace(context);
			if (_publisherNamespace.isEnc){
				if (decryptionKey!=null){
					this.decrypt(decryptionKey);
				}
				else{
					context = new XMPMeta("");
					_publisherNamespace = new PublisherNamespace(context);
					PublisherNamespaceXMPContextStatus._status = PublisherNamespaceXMPContextStatus.MISSING_DECRYPTION_KEY;
				}
			}
		}
		
		/**
		 * Object representing the publisherNamespace namespace and its properties
		 */
		public function get publisherNamespace():PublisherNamespace{
			return this._publisherNamespace;
		}
		
		/**
		 * Registers a class so that its bound variables dynamically update properties of the publisherNamespace namespace
		 * @param caller The instance of a class containing bindable variables
		 */
		public function registerClassBindings( caller:Object ):void{
			var typexml:XML = describeType(caller);
			var classname:String = flash.utils.getQualifiedClassName(caller);
			var accessors:XMLList = typexml.accessor.(attribute("declaredBy") == classname);
			var boundProperties:Array = new Array();
			
			for each (var classElement:XML in accessors) {
				if (classElement.metadata.(attribute("name") == "xmp").length()){
					var variableName:String = classElement.attribute("name");
					var nsPrefix:String = "";
					var propertyName:String = "";
					var xmpMetadata:XMLList = classElement.elements("metadata").(attribute("name")=="xmp")
					for each (var arg:XML in xmpMetadata.elements("arg")){
						if (arg.attribute("key")=="ns")
							nsPrefix = arg.attribute("value");
						if (arg.attribute("key")=="property")
							propertyName = arg.attribute("value");
					}
					if (false||(propertyName == "assetsMetadata")||(propertyName == "exportPath"))
						setSimpleBindings(caller,variableName,nsPrefix,propertyName,"string");
					if (false)
						setSimpleBindings(caller,variableName,nsPrefix,propertyName,"number");
					if (false)
						setSimpleBindings(caller,variableName,nsPrefix,propertyName,"boolean");
					if (false)
						setSimpleBindings(caller,variableName,nsPrefix,propertyName,"object");
					if (false){
						setArrayBindings(caller,variableName,nsPrefix,propertyName);
					}
				} 
			}
		}
		
		private function setSimpleBindings(caller:Object,variableName:String,nsPrefix:String,propertyName:String,vartype:String):void{
			if (typeof(caller[variableName])==vartype){
				publisherNamespace[propertyName]=caller[variableName];
				ChangeWatcher.watch(caller, variableName, 
					function(e:PropertyChangeEvent):void {
						publisherNamespace[propertyName]=caller[variableName]; 
					}
				);
				ChangeWatcher.watch(publisherNamespace,propertyName,
					function(e:PropertyChangeEvent):void {
						caller[variableName] = publisherNamespace[propertyName];		
					}
				);	
			}
		}
		
		private function setArrayBindings(caller:Object,variableName:String,nsPrefix:String,propertyName:String):void{
			if (flash.utils.getQualifiedClassName(caller[variableName])=="Array"){
				publisherNamespace[propertyName][propertyName+"Items"] = caller[variableName];
				ChangeWatcher.watch(caller, variableName, 
					function(e:PropertyChangeEvent):void {
						publisherNamespace[propertyName][propertyName+"Items"]=caller[variableName]; 
					});
				ChangeWatcher.watch(publisherNamespace[propertyName], propertyName+"Items",
					function(e:PropertyChangeEvent):void {
						caller[variableName] = publisherNamespace[propertyName][propertyName+"Items"];		
					});
			}
		}
	
		/**
		 * Returns the entire XMP packet in serialized XML form
		 * @param encryptionKey (optional) Key to be used to encrypt the publisherNamespace namespace
		 */	
		public function serializeToXML(encryptionKey:String = null):String
		{
			return (encryptionKey!=null) ? encrypt(encryptionKey) : context.serialize();
		}
		
		private function makeStripped():PublisherNamespaceXMPContext{
			var stripped:PublisherNamespaceXMPContext = new PublisherNamespaceXMPContext();
			if(!this.publisherNamespace.assetsMetadataIsNull()){
				stripped.publisherNamespace.assetsMetadata = this.publisherNamespace.assetsMetadata;
				this.publisherNamespace.deleteAssetsMetadata();
			}
			if(!this.publisherNamespace.exportPathIsNull()){
				stripped.publisherNamespace.exportPath = this.publisherNamespace.exportPath;
				this.publisherNamespace.deleteExportPath();
			}
			
			
			
			return stripped;
		}
		
		/**
		 * Encrypts all existing properties of the publisherNamespace namespace
		 * @param key The key to be used for encryption 
		 */	
		private function encrypt(key:String):String
		{
			var unencrypted:String = context.serialize();
			var hashAlgorithm:SHA256 = new SHA256();
			var keyBytes:ByteArray = Hex.toArray(Hex.fromString(key));
			var hashedKeyBytes:ByteArray = hashAlgorithm.hash(keyBytes);
			
			var cipher:ByteArray = new ByteArray();
			cipher.writeUTFBytes(makeStripped().serializeToXML());
			var padding:IPad = new PKCS5();
			var mode:ICipher = com.hurlant.crypto.Crypto.getCipher("aes",hashedKeyBytes,padding);
			padding.setBlockSize(mode.getBlockSize());
			mode.encrypt(cipher);
			var initialisationVector:String = ""; 
			if (mode is IVMode) 
			{
				var ivmode:IVMode = mode as IVMode;
				initialisationVector= com.hurlant.util.Hex.fromArray(ivmode.IV);
			}
			cipher.position = 0;
			var hexString:String = ""
			while (cipher.bytesAvailable > 0) 
			{
				var hexByte:String = cipher.readUnsignedByte().toString(16); 
				switch(hexByte.length) 
				{
					case 2:
						hexString += hexByte;
						break;
					case 1:
						hexString += "0"+hexByte;
						break;
					case 0:
						hexString += "00";
						break;
				}
			}
			context = new XMPMeta(unencrypted);
			_publisherNamespace = new PublisherNamespace(context);
			var encrypted:PublisherNamespaceXMPContext = new PublisherNamespaceXMPContext(unencrypted);
			
			
				encrypted.publisherNamespace.deleteAssetsMetadata();
			
				encrypted.publisherNamespace.deleteExportPath();
			
			
			
			
			encrypted.publisherNamespace.encPacket = hexString;
			encrypted.publisherNamespace.initVector = initialisationVector;
			encrypted.publisherNamespace.isEnc = true;
			return encrypted.serializeToXML();
		}
		
		/**
		 * Decrypts any encrypted properties of the publisherNamespace namespace
		 * @param key The key to be used for decryption 
		 */	
		private function decrypt(key:String):void
		{
			var hashAlgorithm:SHA256 = new SHA256();
			var keyBytes:ByteArray = Hex.toArray(Hex.fromString(key));
			var hashedKeyBytes:ByteArray = hashAlgorithm.hash(keyBytes);
		
			var padding:IPad = new PKCS5();
			var mode:ICipher = com.hurlant.crypto.Crypto.getCipher("aes",hashedKeyBytes,padding);
			padding.setBlockSize(mode.getBlockSize());
			var initialisationVector:String = this.publisherNamespace.initVector;
			if (mode is IVMode) 
			{
				var ivmode:IVMode = mode as IVMode;
				ivmode.IV = com.hurlant.util.Hex.toArray(initialisationVector);
			}
			var ciphertext:String = this.publisherNamespace.encPacket;
			var end:int = 2;
			var cipher:ByteArray = new ByteArray;			
			while (end <= ciphertext.length) 
			{
				cipher.writeByte(new int("0x"+ciphertext.substring(end-2,end)));
				end = end + 2;
			}
			cipher.position = 0;
			try {
				mode.decrypt(cipher);
			}
			catch (e:Error) {
				throw new XMPDecryptionError();
			}
			var decrypted:PublisherNamespaceXMPContext = new PublisherNamespaceXMPContext(cipher.toString());
			this.publisherNamespace.assetsMetadata = decrypted.publisherNamespace.assetsMetadata;
			this.publisherNamespace.exportPath = decrypted.publisherNamespace.exportPath;
			
			
			this.publisherNamespace.encPacket = null;
			this.publisherNamespace.deleteIsEnc();
			this.publisherNamespace.initVector = null;
		}
	}
}
