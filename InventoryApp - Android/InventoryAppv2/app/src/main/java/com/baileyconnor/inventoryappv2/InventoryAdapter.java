package com.baileyconnor.inventoryappv2;

import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.baileyconnor.inventoryappv2.model.Item;

import java.util.List;

public class InventoryAdapter extends RecyclerView.Adapter<InventoryAdapter.Holder> {

    public interface Listener {
        void onClick(Item item);
        void onLongPress(Item item);
    }

    private List<Item> data;
    private final Listener listener;

    public InventoryAdapter(List<Item> data, Listener listener) {
        this.data = data;
        this.listener = listener;
    }

    public void submit(List<Item> updated) {
        this.data = updated;
        notifyDataSetChanged();
    }

    @NonNull @Override
    public Holder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.inventory_cell, parent, false);
        return new Holder(v);
    }

    @Override public int getItemCount() {
        return data == null ? 0 : data.size();
    }

    @Override public void onBindViewHolder(@NonNull Holder h, int pos) {
        Item item = data.get(pos);
        h.tvName.setText(item.getName());
        h.tvQty.setText(String.valueOf(item.getQuantity()));

        h.itemView.setOnClickListener(v -> listener.onClick(item));
        h.itemView.setOnLongClickListener(v -> {
            listener.onLongPress(item);
            return true;
        });
    }

    static class Holder extends RecyclerView.ViewHolder {
        TextView tvName, tvQty;
        Holder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvName);
            tvQty = itemView.findViewById(R.id.tvQty);
        }
    }
}
