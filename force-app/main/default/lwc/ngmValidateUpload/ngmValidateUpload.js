import { LightningElement, track } from 'lwc';
import saveFile from '@salesforce/apex/NGMFileUploadController.saveFile';
import mammoth from '@salesforce/resourceUrl/ngmMammoth';
// import pdfjsLib from '@salesforce/resourceUrl/NGMPdfjs';
import { loadScript } from 'lightning/platformResourceLoader';
export default class NgmValidateUpload extends LightningElement {
 @track errorMessage;
    @track successMessage;
    @track validationText = '';

    librariesLoaded = false;

    renderedCallback() {
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;

        Promise.all([
            loadScript(this, mammoth + '/mammoth.browser.min.js'),
            // loadScript(this, pdfjsLib + '/pdf.min.js')
        ]).catch(error => {
            console.error('Error loading libraries', error);
        });
    }

    handleTextChange(event) {
        this.validationText = event.target.value;
    }

    async handleFileChange(event) {
        this.errorMessage = null;
        this.successMessage = null;

        const file = event.target.files[0];
        if (!file) return;

        let textContent = '';

        try {
            if (file.name.endsWith('.docx')) {
                textContent = await this.readDocx(file);
            } else if (file.name.endsWith('.pdf')) {
                textContent = await this.readPdf(file);
            } else {
                this.errorMessage = 'Unsupported file type.';
                return;
            }
        } catch (e) {
            this.errorMessage = 'Error reading file: ' + e.message;
            return;
        }

        // validation: must contain dynamic text
        if (!this.validationText || !textContent.toLowerCase().includes(this.validationText.toLowerCase())) {
            this.errorMessage = 'Validation failed: Document must mention "' + this.validationText + '".';
            return;
        }
        console.log('file >> ', file);
        this.uploadFile(file);
    }

    readDocx(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = async e => {
                try {
                    const arrayBuffer = e.target.result;
                    const result = await window.mammoth.extractRawText({ arrayBuffer });
                    resolve(result.value);
                } catch (err) {
                    reject(err);
                }
            };
            reader.onerror = () => reject(reader.error);
            reader.readAsArrayBuffer(file);
        });
    }

    async readPdf(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = async e => {
                try {
                    const typedArray = new Uint8Array(e.target.result);
                    const pdf = await window['pdfjs-dist/build/pdf'].getDocument(typedArray).promise;
                    let textContent = '';
                    for (let i = 1; i <= pdf.numPages; i++) {
                        const page = await pdf.getPage(i);
                        const text = await page.getTextContent();
                        text.items.forEach(item => {
                            textContent += item.str + ' ';
                        });
                    }
                    resolve(textContent);
                } catch (err) {
                    reject(err);
                }
            };
            reader.onerror = () => reject(reader.error);
            reader.readAsArrayBuffer(file);
        });
    }

    uploadFile(file) {
        console.log('file >> ', file);
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            console.log('file >> ', file.name);
            saveFile({ fileName: file.name, base64Data: base64 })
                .then(() => {
                    this.successMessage = 'File uploaded successfully!';
                })
                .catch(err => {
                    this.errorMessage = 'Upload failed: ' + err.body.message;
                });
        };
        reader.readAsDataURL(file);
    }

}