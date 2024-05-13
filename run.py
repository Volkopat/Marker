import gradio as gr
import subprocess
import os
import shutil

workers = "4"

def _fProcessDocument(input_file, output_name):
    message = ""
    if input_file is None:
        return "File upload is required.", None
    if not output_name:
        return "Output file name is required.", None

    input_dir = os.path.dirname(input_file.name)
    input_path = input_file.name
    output_dir = os.path.join(input_dir, output_name)
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, "output.md")

    subprocess.run(["python", "convert_single.py", input_path, output_path, "--batch_multiplier", workers], check=True)
    message = "File processed successfully. Output saved."

    # Create a ZIP archive of the output directory
    zip_path = os.path.join(input_dir, f"{output_name}.zip")
    shutil.make_archive(zip_path[:-4], 'zip', output_dir)

    return message, zip_path

def _fUploadStatus(input_file):
    if input_file is not None:
        return "File uploaded successfully."
    return ""

with gr.Blocks() as demo:
    gr.Markdown("# Document Converter")
    gr.Markdown("Upload a document and provide an output file name to convert it.")

    with gr.Row():
        file_input = gr.File(label="Upload your document")
        output_name_input = gr.Textbox(label="Name your output file")
        submit_button = gr.Button("Process")

    message_output = gr.Text(label="Messages")
    download_output = gr.File(label="Download Processed File", visible=True)

    file_input.change(fn=_fUploadStatus, inputs=file_input, outputs=message_output)
    submit_button.click(fn=_fProcessDocument, inputs=[file_input, output_name_input], outputs=[message_output, download_output])

demo.launch(server_name="0.0.0.0", server_port=7860)